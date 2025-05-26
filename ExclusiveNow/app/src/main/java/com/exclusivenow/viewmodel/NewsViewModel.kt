package com.exclusivenow.viewmodel

import android.app.Application
import android.util.Log
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.exclusivenow.api.NewsApiHelper
import com.exclusivenow.model.Article
import com.exclusivenow.model.NewsResponse
import com.exclusivenow.model.UserProfile
import com.google.firebase.auth.ktx.auth
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext
import retrofit2.Response

class NewsViewModel(application: Application) : AndroidViewModel(application) {

    private val _topHeadlines = MutableLiveData<List<Article>>()
    val topHeadlines: LiveData<List<Article>> = _topHeadlines

    private val _categorizedNews = MutableLiveData<List<Article>>()
    val categorizedNews: LiveData<List<Article>> = _categorizedNews

    private val _errorMessage = MutableLiveData<String>()
    val errorMessage: LiveData<String> = _errorMessage

    private val newsApiService = NewsApiHelper.getInstance()

    private val db = Firebase.firestore
    private val auth = Firebase.auth
    private val _userProfile = MutableLiveData<UserProfile?>()
    val userProfile: LiveData<UserProfile?> = _userProfile

    init {
        loadUserProfile()
    }

    fun fetchTopHeadlines(apiKey: String) {
        viewModelScope.launch {
            try {
                val response = withContext(Dispatchers.IO) {
                    newsApiService.getTopHeadlines(apiKey = apiKey)
                }
                handleResponse(response, _topHeadlines)
            } catch (e: Exception) {
                handleException(e, _topHeadlines)
            }
        }
    }

    fun fetchCategorizedNews(apiKey: String, category: String) {
        viewModelScope.launch {
            try {
                val response = withContext(Dispatchers.IO) {
                    newsApiService.getCategorizedHeadlines(apiKey = apiKey, category = category)
                }
                handleResponse(response, _categorizedNews)
            } catch (e: Exception) {
                handleException(e, _categorizedNews)
            }
        }
    }

    private fun handleResponse(response: Response<NewsResponse>, liveData: MutableLiveData<List<Article>>) {
        if (response.isSuccessful) {
            val newsResponse = response.body()
            val articlesList = newsResponse?.articles ?: emptyList()
            liveData.postValue(articlesList)
            _errorMessage.postValue(null)
        } else {
            val errorBody = response.errorBody()?.string() ?: "Unknown error"
            _errorMessage.postValue("API Error: ${response.code()} ${response.message()} - Body: $errorBody")
            liveData.postValue(emptyList())
        }
    }
    private fun handleException(e: Exception, liveData: MutableLiveData<List<Article>>) {
        _errorMessage.postValue("Network error or exception: ${e.message}")
        liveData.postValue(emptyList())
    }


    fun createUserProfile(username: String, userId: String, profilePictureUrl: String? = null, interests: List<String>? = null) {

        val newProfile = UserProfile(userId, username, profilePictureUrl, interests ?: emptyList())

        viewModelScope.launch(Dispatchers.IO) {
            try {
                val documentReference = db.collection("users").add(newProfile).await()
                val updatedProfile = newProfile.copy(documentId = documentReference.id)
                db.collection("users").document(documentReference.id).set(updatedProfile).await()
                _userProfile.postValue(updatedProfile)

            } catch (e: Exception) {
                _errorMessage.postValue("Error creating profile: ${e.localizedMessage}")
            }
        }
    }

    fun updateUserProfile(username: String, profilePictureUrl: String? = null, interests: List<String>? = null) {
        val currentProfile = _userProfile.value
        if (currentProfile == null) {
            _errorMessage.value = "No profile to update."
            return
        }

        val updatedProfile = currentProfile.copy(
            username = username,
            profilePictureUrl = profilePictureUrl ?: currentProfile.profilePictureUrl,
            interests = interests ?: currentProfile.interests
        )

        viewModelScope.launch(Dispatchers.IO) {
            try {
                db.collection("users").document(updatedProfile.documentId).set(updatedProfile).await()
                _userProfile.postValue(updatedProfile)
            } catch (e: Exception) {
                _errorMessage.postValue("Error updating profile: ${e.localizedMessage}")
            }
        }
    }
    fun addInterest(interest: String) {
        val currentProfile = _userProfile.value ?: return
        val updatedInterests = currentProfile.interests.toMutableList().apply { add(interest) }
        updateUserProfile(currentProfile.username, currentProfile.profilePictureUrl, updatedInterests)
    }

    fun removeInterest(interest: String) {
        val currentProfile = _userProfile.value ?: return
        val updatedInterests = currentProfile.interests.toMutableList().apply { remove(interest) }
        updateUserProfile(currentProfile.username, currentProfile.profilePictureUrl, updatedInterests)
    }
    fun fetchNewsByInterests(apiKey: String) {
        val userProfile = _userProfile.value ?: return

        viewModelScope.launch {
            val allCategorizedNews = mutableListOf<Article>()
            for (interest in userProfile.interests) {
                try {
                    val response = withContext(Dispatchers.IO) {
                        newsApiService.getCategorizedHeadlines(apiKey = apiKey, category = interest)
                    }
                    if (response.isSuccessful) {
                        val newsResponse = response.body()
                        val articlesList = newsResponse?.articles ?: emptyList()
                        allCategorizedNews.addAll(articlesList)
                    }
                } catch (e: Exception) {
                }
            }
            _categorizedNews.postValue(allCategorizedNews)
        }
    }


    fun refreshUserProfile() {
        val user = auth.currentUser ?: return

        viewModelScope.launch(Dispatchers.IO) {
            try {
                val querySnapshot = db.collection("users").whereEqualTo("userId", user.uid).get().await()
                if (!querySnapshot.isEmpty) {
                    val document = querySnapshot.documents.first()
                    val profile = document.toObject(UserProfile::class.java)
                    if (profile != null) {
                        val updatedProfile = profile.copy(documentId = document.id)
                        withContext(Dispatchers.Main) {
                            _userProfile.value = updatedProfile
                        }
                    } else {
                        withContext(Dispatchers.Main) {
                            _userProfile.value = null
                        }
                    }
                } else {
                    withContext(Dispatchers.Main) {
                        _userProfile.value = null
                    }
                }
            } catch (e: Exception) {
                _errorMessage.postValue("Error refreshing profile: ${e.localizedMessage}")
                withContext(Dispatchers.Main) {
                    _userProfile.value = null
                }
            }
        }
    }

    fun loadUserProfile() {
        val user = auth.currentUser
        if (user == null) {
            viewModelScope.launch(Dispatchers.Main) {
                _userProfile.value = null
            }
            return
        }

        val userId = user.uid
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val querySnapshot = db.collection("users").whereEqualTo("userId", userId).get().await()
                if (!querySnapshot.isEmpty) {
                    val document = querySnapshot.documents.first()
                    val profile = document.toObject(UserProfile::class.java)
                    if (profile != null) {
                        val updatedProfile = profile.copy(documentId = document.id)
                        withContext(Dispatchers.Main) {
                            _userProfile.value = updatedProfile
                        }
                    } else {
                        withContext(Dispatchers.Main) {
                            _userProfile.value = null
                        }
                    }
                } else {
                    withContext(Dispatchers.Main) {
                        _userProfile.value = null
                    }
                }
            } catch (e: Exception) {
                _errorMessage.postValue("Error loading profile: ${e.localizedMessage}")
                withContext(Dispatchers.Main) {
                    _userProfile.value = null
                }
            }
        }
    }

    fun isUserLoggedIn(): Boolean {
        return auth.currentUser != null
    }

}