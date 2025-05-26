package com.exclusivenow.model

data class UserProfile(
    val userId: String = "",
    var username: String = "",
    var profilePictureUrl: String? = null,
    var interests: List<String> = emptyList(),
    var documentId: String = ""
)