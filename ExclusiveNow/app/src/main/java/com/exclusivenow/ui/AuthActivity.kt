package com.exclusivenow.ui

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.ProgressBar
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import com.exclusivenow.MainActivity
import com.exclusivenow.R
import com.exclusivenow.databinding.ActivityAuthBinding
import com.exclusivenow.viewmodel.AuthViewModel
import com.exclusivenow.viewmodel.NewsViewModel
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.tasks.Task
import com.google.android.material.chip.Chip
import com.google.android.material.snackbar.Snackbar
import com.google.firebase.auth.ktx.auth
import com.google.firebase.ktx.Firebase

class AuthActivity : AppCompatActivity() {

    private lateinit var binding: ActivityAuthBinding
    private val authViewModel: AuthViewModel by viewModels()
    private val newsViewModel: NewsViewModel by viewModels()
    private lateinit var googleSignInClient: GoogleSignInClient
    private val RC_SIGN_IN = 123
    private val availableInterests = listOf("sports", "technology", "politics", "business", "entertainment", "health")
    private lateinit var progressBar: ProgressBar

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityAuthBinding.inflate(layoutInflater)
        setContentView(binding.root)

        progressBar = binding.progressBar

        setupGoogleSignIn()
        setupClickListeners()
        observeAuthenticationState()
        addInterestChips()
    }

    private fun setupGoogleSignIn() {
        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestIdToken(getString(R.string.default_web_client_id))
            .requestEmail()
            .build()
        googleSignInClient = GoogleSignIn.getClient(this, gso)
    }

    private fun setupClickListeners() {
        binding.emailSignInButton.setOnClickListener {
            signInWithEmail()
        }
        binding.emailSignUpButton.setOnClickListener {
            signUpWithEmail()
        }
        binding.googleSignInButton.setOnClickListener {
            signInWithGoogle()
        }
        binding.saveInterestsButton.setOnClickListener{
            saveUserInterests()
        }
    }

    private fun observeAuthenticationState() {
        authViewModel.authenticationState.observe(this) { state ->
            when (state) {
                is AuthViewModel.AuthenticationState.Authenticated -> {
                    hideProgressBar()
                    goToMainActivity()
                }
                is AuthViewModel.AuthenticationState.Unauthenticated -> {
                    hideProgressBar()
                }
                is AuthViewModel.AuthenticationState.Loading -> {
                    showProgressBar()
                }
                is AuthViewModel.AuthenticationState.Error -> {
                    hideProgressBar()
                    Snackbar.make(binding.root, state.message, Snackbar.LENGTH_LONG).show()
                }
            }
        }
    }


    private fun signInWithEmail() {
        val email = binding.emailEditText.text.toString().trim()
        val password = binding.passwordEditText.text.toString().trim()

        if (email.isEmpty() || password.isEmpty()) {
            Snackbar.make(binding.root, "Please enter email and password.", Snackbar.LENGTH_SHORT).show()
            return
        }

        authViewModel.signInWithEmail(email, password) {
            newsViewModel.loadUserProfile()
            goToMainActivity()

        }
    }

    private fun signUpWithEmail() {
        val email = binding.emailEditText.text.toString().trim()
        val password = binding.passwordEditText.text.toString().trim()

        if (email.isEmpty() || password.isEmpty()) {
            Snackbar.make(binding.root, "Please enter email and password.", Snackbar.LENGTH_SHORT).show()
            return
        }
        if (password.length < 6) {
            Snackbar.make(binding.root, "Password must be at least 6 characters.", Snackbar.LENGTH_SHORT).show()
            return
        }


        authViewModel.signUpWithEmail(email, password) {
            showNameAndInterestsInput()
        }
    }


    private fun signInWithGoogle() {
        val signInIntent = googleSignInClient.signInIntent
        startActivityForResult(signInIntent, RC_SIGN_IN)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == RC_SIGN_IN) {
            val task = GoogleSignIn.getSignedInAccountFromIntent(data)
            handleGoogleSignInResult(task)
        }
    }

    private fun handleGoogleSignInResult(completedTask: Task<GoogleSignInAccount>) {
        try {
            val account = completedTask.getResult(ApiException::class.java)
            account?.idToken?.let { idToken ->
                authViewModel.signInWithGoogle(idToken) { userId ->
                    newsViewModel.loadUserProfile()

                    newsViewModel.userProfile.observe(this) { userProfile ->
                        if (userProfile == null) {
                            showNameAndInterestsInput()
                        } else {
                            goToMainActivity()
                        }
                        newsViewModel.userProfile.removeObservers(this)
                    }
                }
            }
        } catch (e: ApiException) {
            Snackbar.make(binding.root, "Google Sign-In failed: ${e.message}", Snackbar.LENGTH_LONG).show()
        }
    }


    private fun showNameAndInterestsInput() {
        binding.emailInputLayout.visibility = View.GONE
        binding.passwordInputLayout.visibility = View.GONE
        binding.buttonLayout.visibility = View.GONE
        binding.googleSignInButton.visibility = View.GONE
        binding.textViewOr.visibility = View.GONE

        binding.nameInputLayout.visibility = View.VISIBLE
        binding.interestSelectionTitle.visibility = View.VISIBLE
        binding.interestsChipGroup.visibility = View.VISIBLE
        binding.saveInterestsButton.visibility = View.VISIBLE

    }


    private fun saveUserInterests(){
        val name = binding.nameEditText.text.toString().trim()
        val selectedInterests = binding.interestsChipGroup.checkedChipIds.mapNotNull{ chipId ->
            availableInterests.firstOrNull{it.hashCode() == chipId}
        }

        if (name.isEmpty()) {
            Snackbar.make(binding.root, "Please enter your name.", Snackbar.LENGTH_SHORT).show()
            return
        }

        val userId = authViewModel.authenticationState.value.let{ authState ->
            if(authState is AuthViewModel.AuthenticationState.Authenticated){
                Firebase.auth.currentUser?.uid
            } else {
                null
            }
        } ?: return

        newsViewModel.createUserProfile(username = name, userId = userId, interests = selectedInterests)
        goToMainActivity()

    }
    private fun addInterestChips() {
        for (interest in availableInterests) {
            val chip = Chip(this)
            chip.text = interest
            chip.isCheckable = true
            chip.id = interest.hashCode()
            binding.interestsChipGroup.addView(chip)
        }
    }

    private fun goToMainActivity() {
        val intent = Intent(this, MainActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        startActivity(intent)
        finish()
    }
    private fun showProgressBar() {
        progressBar.visibility = View.VISIBLE
    }

    private fun hideProgressBar() {
        progressBar.visibility = View.GONE
    }
}