package com.exclusivenow.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.GoogleAuthProvider
import com.google.firebase.auth.ktx.auth
import com.google.firebase.ktx.Firebase
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await

class AuthViewModel : ViewModel() {

    private val _authenticationState = MutableLiveData<AuthenticationState>()
    val authenticationState: LiveData<AuthenticationState> = _authenticationState

    private var auth: FirebaseAuth = Firebase.auth

    sealed class AuthenticationState {
        object Authenticated : AuthenticationState()
        object Unauthenticated : AuthenticationState()
        object Loading : AuthenticationState()
        data class Error(val message: String) : AuthenticationState()
    }
    init {
        if (auth.currentUser != null) {
            _authenticationState.value = AuthenticationState.Authenticated
        } else {
            _authenticationState.value = AuthenticationState.Unauthenticated
        }
    }

    fun signInWithEmail(email: String, password: String, onComplete: (String)->Unit) {
        _authenticationState.value = AuthenticationState.Loading

        viewModelScope.launch {
            try {
                val authResult = auth.signInWithEmailAndPassword(email, password).await()
                val user = authResult.user

                if(user!=null){
                    onComplete(user.uid)
                }
                _authenticationState.postValue(AuthenticationState.Authenticated)

            } catch (e: Exception) {
                _authenticationState.postValue(AuthenticationState.Error("Authentication failed: ${e.localizedMessage}"))
            }
        }
    }

    fun signUpWithEmail(email: String, password: String, onComplete: (String) -> Unit) {
        _authenticationState.value = AuthenticationState.Loading

        viewModelScope.launch {
            try {
                val authResult = auth.createUserWithEmailAndPassword(email, password).await()
                val user = authResult.user
                if(user!=null){
                    onComplete(user.uid)
                }
                _authenticationState.postValue(AuthenticationState.Authenticated)
            } catch (e: Exception) {
                _authenticationState.postValue(AuthenticationState.Error("Account creation failed: ${e.localizedMessage}"))
            }
        }
    }

    fun signInWithGoogle(idToken: String, onComplete: (String) -> Unit) {
        _authenticationState.value = AuthenticationState.Loading

        viewModelScope.launch {
            try {
                val credential = GoogleAuthProvider.getCredential(idToken, null)
                val authResult =  auth.signInWithCredential(credential).await()
                val user = authResult.user
                if(user!=null){
                    onComplete(user.uid)
                }
                _authenticationState.postValue(AuthenticationState.Authenticated)
            } catch (e: Exception) {
                _authenticationState.postValue(AuthenticationState.Error("Google Sign-In Failed: ${e.localizedMessage}"))
            }
        }
    }

    fun signOut() {
        auth.signOut()
        _authenticationState.value = AuthenticationState.Unauthenticated
    }
}