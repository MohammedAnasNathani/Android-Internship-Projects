package com.exclusivenow.model

import androidx.room.Entity
import androidx.room.PrimaryKey
import android.os.Parcelable
import kotlinx.parcelize.Parcelize
import java.util.Date

@Parcelize
@Entity(tableName = "saved_articles")
data class SavedArticle(
    @PrimaryKey(autoGenerate = true) var id: Int = 0,
    var sourceId: String? = null,
    var sourceName: String? = null,
    var author: String? = null,
    var title: String? = null,
    var description: String? = null,
    var url: String? = null,
    var urlToImage: String? = null,
    var publishedAt: String? = null,
    var content: String? = null,
    var savedAt: Long = Date().time
) : Parcelable {
    constructor() : this(0, null, null, null, null, null, null, null, null, null)
}