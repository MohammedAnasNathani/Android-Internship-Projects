package com.exclusivenow

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.ImageButton
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.app.AppCompatDelegate
import androidx.lifecycle.lifecycleScope
import com.exclusivenow.databinding.ActivityMainBinding
import com.exclusivenow.model.Article
import com.exclusivenow.model.toSavedArticle
import com.exclusivenow.ui.ArticleDetailActivity
import com.exclusivenow.ui.AuthActivity
import com.exclusivenow.ui.EditProfileActivity
import com.exclusivenow.ui.NewsAdapter
import com.exclusivenow.ui.SavedArticlesActivity
import com.exclusivenow.viewmodel.NewsViewModel
import com.exclusivenow.viewmodel.SavedArticleViewModel
import com.google.android.material.snackbar.Snackbar
import com.google.android.material.tabs.TabLayout
import com.google.firebase.auth.ktx.auth
import com.google.firebase.ktx.Firebase
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.Calendar

class MainActivity : AppCompatActivity(), NewsAdapter.OnItemClickListener, NewsAdapter.OnSaveClickListener {

    private lateinit var binding: ActivityMainBinding
    private val newsViewModel: NewsViewModel by viewModels()
    private val savedArticleViewModel: SavedArticleViewModel by viewModels()
    private lateinit var newsAdapter: NewsAdapter
    private lateinit var sharedPreferences: SharedPreferences
    private lateinit var darkModeButton: ImageButton
    private var auth = Firebase.auth
    private var selectedTabIndex = 0


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        sharedPreferences = getSharedPreferences("AppSettings", Context.MODE_PRIVATE)
        loadDarkModeState()

        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setSupportActionBar(binding.toolbar)
        darkModeButton = binding.toolbar.findViewById(R.id.darkModeButton)
        updateDarkModeButtonIcon()
        darkModeButton.setOnClickListener { toggleDarkMode() }


        newsAdapter = NewsAdapter(this, this)
        binding.newsRecyclerView.adapter = newsAdapter

        if (savedInstanceState != null) {
            selectedTabIndex = savedInstanceState.getInt(KEY_SELECTED_TAB, 0)
        }

        observeViewModel()
        setupTabLayout()

        if (auth.currentUser == null) {
            startActivity(Intent(this, AuthActivity::class.java))
            finish()
            return
        }
    }

    override fun onResume() {
        super.onResume()
        loadNewsData()
    }

    private fun loadNewsData() {
        newsViewModel.userProfile.observe(this) { userProfile ->
            if (userProfile != null) {
                displayGreeting()
                selectNewsTab()
            } else {
                fetchTopNews()
            }
            newsViewModel.userProfile.removeObservers(this)
        }
    }

    private fun selectNewsTab(){
        when (selectedTabIndex) {
            0 -> fetchPersonalizedNews()
            1 -> fetchTopNews()
            else -> {
                val category = binding.tabLayoutCategories.getTabAt(selectedTabIndex)?.tag as? String
                    ?: return
                fetchCategorizedNews(category)
            }
        }
    }

    private fun displayGreeting() {
        newsViewModel.userProfile.value?.let { profile ->
            val greeting = getGreeting()
            binding.toolbar.title = "$greeting, ${profile.username}"
        }
    }


    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.main_menu, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.action_saved_articles -> {
                startActivity(Intent(this, SavedArticlesActivity::class.java))
                true
            }
            R.id.action_logout -> {
                auth.signOut()
                startActivity(Intent(this, AuthActivity::class.java))
                finish()
                true
            }
            R.id.action_edit_profile -> {
                startActivity(Intent(this, EditProfileActivity::class.java))
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    private fun setupTabLayout() {
        binding.tabLayoutCategories.addOnTabSelectedListener(object : TabLayout.OnTabSelectedListener {
            override fun onTabSelected(tab: TabLayout.Tab?) {
                selectedTabIndex = tab?.position ?: 0

                val category = tab?.tag as? String
                if (category == "my_feed") {
                    if (newsViewModel.isUserLoggedIn() && newsViewModel.userProfile.value != null) {
                        fetchPersonalizedNews()
                    } else {
                        fetchTopNews()
                    }
                } else if (category != null) {
                    fetchCategorizedNews(category)
                } else {
                    fetchTopNews()
                }
            }

            override fun onTabUnselected(tab: TabLayout.Tab?) {}
            override fun onTabReselected(tab: TabLayout.Tab?) {
                onTabSelected(tab)
            }
        })

        binding.tabLayoutCategories.addTab(binding.tabLayoutCategories.newTab().setText("My Feed").setTag("my_feed"), 0)
        binding.tabLayoutCategories.addTab(binding.tabLayoutCategories.newTab().setText("Top News").setTag(null), 1)
        binding.tabLayoutCategories.addTab(binding.tabLayoutCategories.newTab().setText("Sports").setTag("sports"), 2)
        binding.tabLayoutCategories.addTab(binding.tabLayoutCategories.newTab().setText("Technology").setTag("technology"), 3)
        binding.tabLayoutCategories.addTab(binding.tabLayoutCategories.newTab().setText("Politics").setTag("politics"), 4)
        binding.tabLayoutCategories.addTab(binding.tabLayoutCategories.newTab().setText("Business").setTag("business"), 5)
        binding.tabLayoutCategories.addTab(binding.tabLayoutCategories.newTab().setText("Entertainment").setTag("entertainment"), 6)
        binding.tabLayoutCategories.addTab(binding.tabLayoutCategories.newTab().setText("Health").setTag("health"), 7)

        binding.tabLayoutCategories.getTabAt(selectedTabIndex)?.select()
    }


    private fun observeViewModel() {
        newsViewModel.topHeadlines.observe(this) { articles ->
            binding.loadingProgressBar.visibility = View.GONE
            binding.errorTextView.visibility = View.GONE
            updateNewsAdapter(articles)
        }

        newsViewModel.categorizedNews.observe(this) { articles ->
            binding.loadingProgressBar.visibility = View.GONE
            binding.errorTextView.visibility = View.GONE
            updateNewsAdapter(articles)
        }

        newsViewModel.errorMessage.observe(this) { errorMessage ->
            binding.loadingProgressBar.visibility = View.GONE
            if (errorMessage != null) {
                binding.errorTextView.visibility = View.VISIBLE
                binding.errorTextView.text = errorMessage
            } else {
                binding.errorTextView.visibility = View.GONE
            }
        }

        savedArticleViewModel.savedArticles.observe(this) { savedArticles ->
            val savedUrls = savedArticles.mapNotNull { it.url }
            val currentNews = when (binding.tabLayoutCategories.getTabAt(selectedTabIndex)?.tag) {
                "my_feed" -> newsViewModel.categorizedNews.value
                null -> newsViewModel.topHeadlines.value
                else -> newsViewModel.categorizedNews.value
            }
            newsAdapter.setArticles(currentNews ?: emptyList(), savedUrls)
        }

    }


    private fun updateNewsAdapter(articles: List<Article>) {
        val savedUrls = savedArticleViewModel.savedArticles.value?.mapNotNull { it.url } ?: emptyList()
        newsAdapter.setArticles(articles, savedUrls)
    }


    private fun fetchTopNews() {
        binding.loadingProgressBar.visibility = View.VISIBLE
        binding.errorTextView.visibility = View.GONE
        newsViewModel.fetchTopHeadlines(API_KEY)
    }

    private fun fetchCategorizedNews(category: String) {
        binding.loadingProgressBar.visibility = View.VISIBLE
        binding.errorTextView.visibility = View.GONE
        newsViewModel.fetchCategorizedNews(API_KEY, category)
    }

    private fun fetchPersonalizedNews() {
        binding.loadingProgressBar.visibility = View.VISIBLE
        binding.errorTextView.visibility = View.GONE
        newsViewModel.fetchNewsByInterests(API_KEY)
    }

    override fun onItemClick(article: Article) {
        val intent = ArticleDetailActivity.newIntent(this, article)
        startActivity(intent)
    }

    override fun onSaveClick(article: Article, position: Int) {
        lifecycleScope.launch(Dispatchers.IO) {
            try {
                savedArticleViewModel.saveArticle(article.toSavedArticle())
                withContext(Dispatchers.Main) {
                    newsAdapter.notifyItemChanged(position, true)
                    Snackbar.make(binding.root, "Article saved!", Snackbar.LENGTH_SHORT).show()
                }
            } catch (e: Exception){
                withContext(Dispatchers.Main){
                    Snackbar.make(binding.root, "Failed to save article!", Snackbar.LENGTH_SHORT).show()
                }
            }
        }
    }
    override fun onUnsaveClick(article: Article, position: Int) {
        lifecycleScope.launch(Dispatchers.IO) {
            try{
                savedArticleViewModel.deleteSavedArticle(article.toSavedArticle())
                withContext(Dispatchers.Main) {
                    newsAdapter.notifyItemChanged(position, false)
                    Snackbar.make(binding.root, "Article unsaved!", Snackbar.LENGTH_SHORT).show()
                }
            } catch (e: Exception){
                withContext(Dispatchers.Main){
                    Snackbar.make(binding.root, "Failed to unsave article!", Snackbar.LENGTH_SHORT).show()
                }
            }
        }
    }

    private fun toggleDarkMode() {
        val isDarkModeOn = AppCompatDelegate.getDefaultNightMode() != AppCompatDelegate.MODE_NIGHT_YES
        val newMode = if (isDarkModeOn) {
            AppCompatDelegate.MODE_NIGHT_YES
        } else {
            AppCompatDelegate.MODE_NIGHT_NO
        }

        AppCompatDelegate.setDefaultNightMode(newMode)
        saveDarkModeState(isDarkModeOn)
    }

    private fun saveDarkModeState(isDarkModeOn: Boolean) {
        sharedPreferences.edit().putBoolean("DarkModeEnabled", isDarkModeOn).apply()
        updateDarkModeButtonIcon()
        binding.tabLayoutCategories.getTabAt(selectedTabIndex)?.select()
    }

    private fun loadDarkModeState() {
        val isDarkModeOn = sharedPreferences.getBoolean("DarkModeEnabled", false)
        AppCompatDelegate.setDefaultNightMode(if (isDarkModeOn) AppCompatDelegate.MODE_NIGHT_YES else AppCompatDelegate.MODE_NIGHT_NO)
    }

    private fun updateDarkModeButtonIcon() {
        val isDarkModeOn = AppCompatDelegate.getDefaultNightMode() == AppCompatDelegate.MODE_NIGHT_YES
        darkModeButton.setImageResource(
            if (isDarkModeOn) R.drawable.ic_light_mode else R.drawable.ic_night_mode
        )
    }
    companion object {
        const val API_KEY = "e2fe37970e5b41c2952e405217af090e"
        private const val KEY_SELECTED_TAB = "selected_tab"

    }
    private fun getGreeting(): String {
        val calendar = Calendar.getInstance()
        return when (calendar.get(Calendar.HOUR_OF_DAY)) {
            in 0..11 -> "Good Morning"
            in 12..16 -> "Good Afternoon"
            in 17..20 -> "Good Evening"
            else -> "Good Evening"
        }
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putInt(KEY_SELECTED_TAB, selectedTabIndex)
    }
}