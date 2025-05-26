package com.exclusivenow.ui

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.Observer
import com.exclusivenow.R
import com.exclusivenow.model.UserProfile
import com.exclusivenow.viewmodel.NewsViewModel
import com.google.android.material.chip.Chip
import com.google.android.material.chip.ChipGroup
import com.google.android.material.snackbar.Snackbar

class EditProfileActivity : AppCompatActivity() {

    private val newsViewModel: NewsViewModel by viewModels()
    private lateinit var editNameEditText: EditText
    private lateinit var interestsChipGroup: ChipGroup
    private lateinit var saveProfileButton: Button

    private val availableInterests = listOf("sports", "technology", "politics", "business", "entertainment", "health")

    private val userProfileObserver = Observer<UserProfile?> { userProfile ->
        if (userProfile != null) {
            editNameEditText.setText(userProfile.username)

            for (interest in userProfile.interests) {
                val chipId = interest.hashCode()
                val chip = interestsChipGroup.findViewById<Chip>(chipId)
                chip?.isChecked = true
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_edit_profile)

        editNameEditText = findViewById(R.id.editNameEditText)
        interestsChipGroup = findViewById(R.id.editInterestsChipGroup)
        saveProfileButton = findViewById(R.id.saveProfileButton)

        for (interest in availableInterests) {
            val chip = Chip(this)
            chip.text = interest
            chip.isCheckable = true
            chip.id = interest.hashCode()
            interestsChipGroup.addView(chip)
        }

        newsViewModel.userProfile.observe(this, userProfileObserver)


        saveProfileButton.setOnClickListener {
            val newName = editNameEditText.text.toString().trim()
            val selectedInterests = interestsChipGroup.checkedChipIds.mapNotNull { chipId ->
                availableInterests.firstOrNull { it.hashCode() == chipId }
            }

            if (newName.isEmpty()) {
                Snackbar.make(it, "Name cannot be empty", Snackbar.LENGTH_SHORT).show()
                return@setOnClickListener
            }

            newsViewModel.updateUserProfile(username = newName, interests = selectedInterests)
            finish()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        newsViewModel.userProfile.removeObserver(userProfileObserver)
    }
}