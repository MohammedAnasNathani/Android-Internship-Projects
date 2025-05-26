package com.exclusivenow.ui

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import com.exclusivenow.R

class SavedArticlesActivity : AppCompatActivity() {

    private var savedArticlesFragment: SavedArticlesFragment? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_saved_articles)

        savedArticlesFragment = supportFragmentManager.findFragmentById(R.id.saved_articles_container) as? SavedArticlesFragment

        if (savedArticlesFragment == null) {
            savedArticlesFragment = SavedArticlesFragment()
            supportFragmentManager.beginTransaction()
                .replace(R.id.saved_articles_container, savedArticlesFragment!!)
                .commit()
        }
    }

    override fun onResume() {
        super.onResume()
        savedArticlesFragment?.refreshData()
    }
}