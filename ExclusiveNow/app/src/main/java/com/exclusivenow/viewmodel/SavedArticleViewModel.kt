package com.exclusivenow.viewmodel

import android.app.Application
import android.util.Log
import androidx.lifecycle.*
import com.exclusivenow.db.ArticleDatabase
import com.exclusivenow.model.SavedArticle
import com.google.firebase.auth.ktx.auth
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext

class SavedArticleViewModel(application: Application) : AndroidViewModel(application) {

    private val db = Firebase.firestore
    private val auth = Firebase.auth
    private val articleDao = ArticleDatabase.getDatabase(application).articleDao()
    private val _savedArticles = MutableLiveData<List<SavedArticle>>()
    val savedArticles: LiveData<List<SavedArticle>> = _savedArticles


    init {
        loadSavedArticles()
    }

    private fun loadSavedArticles() {
        val user = auth.currentUser ?: return

        viewModelScope.launch(Dispatchers.IO) {
            try {
                val snapshot = db.collection("users").document(user.uid)
                    .collection("savedArticles")
                    .get()
                    .await()

                val articles = snapshot.toObjects(SavedArticle::class.java)

                articleDao.deleteAllArticles()
                articleDao.insertArticles(articles)

                _savedArticles.postValue(articles)

            } catch (e: Exception) {
                Log.e("SavedArticleViewModel", "Error loading saved articles", e)
            }
        }
    }


    fun saveArticle(article: SavedArticle) {
        val user = auth.currentUser ?: return
        val validDocId = article.url?.replace(Regex("[^a-zA-Z0-9]"), "_") ?: return

        viewModelScope.launch(Dispatchers.IO) {
            try {
                articleDao.insertArticle(article)

                db.collection("users").document(user.uid)
                    .collection("savedArticles").document(validDocId)
                    .set(article)
                    .await()

                loadSavedArticles()
            } catch (e: Exception) {
            }
        }
    }



    fun deleteSavedArticle(article: SavedArticle) {
        val user = auth.currentUser ?: return
        val validDocId = article.url?.replace(Regex("[^a-zA-Z0-9]"), "_") ?: return


        viewModelScope.launch(Dispatchers.IO) {
            try {
                articleDao.deleteArticle(article)

                db.collection("users").document(user.uid)
                    .collection("savedArticles").document(validDocId)
                    .delete()
                    .await()
                loadSavedArticles()
            } catch (e: Exception) {
            }
        }
    }

    suspend fun isArticleSaved(articleUrl: String): Boolean {
        val user = auth.currentUser ?: return false
        val validDocId = articleUrl.replace(Regex("[^a-zA-Z0-9]"), "_")

        return withContext(Dispatchers.IO) {
            try {
                val documentSnapshot = db.collection("users").document(user.uid)
                    .collection("savedArticles").document(validDocId)
                    .get().await()
                documentSnapshot.exists()
            } catch (e: Exception) {
                false
            }
        }
    }
}