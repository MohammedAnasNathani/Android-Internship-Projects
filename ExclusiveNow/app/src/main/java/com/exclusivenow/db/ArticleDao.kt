package com.exclusivenow.db

import androidx.lifecycle.LiveData
import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.exclusivenow.model.SavedArticle

@Dao
interface ArticleDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertArticle(article: SavedArticle)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertArticles(articles: List<SavedArticle>)

    @Delete
    suspend fun deleteArticle(article: SavedArticle)

    @Query("SELECT * FROM saved_articles")
    fun getAllSavedArticles(): LiveData<List<SavedArticle>>

    @Query("SELECT EXISTS(SELECT 1 FROM saved_articles WHERE url = :articleUrl)")
    suspend fun isArticleSaved(articleUrl: String): Boolean

    @Query("DELETE FROM saved_articles")
    suspend fun deleteAllArticles()
}