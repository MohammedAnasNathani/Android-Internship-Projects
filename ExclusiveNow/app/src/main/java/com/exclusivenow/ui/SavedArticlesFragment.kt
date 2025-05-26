package com.exclusivenow.ui

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.PopupMenu
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.recyclerview.widget.LinearLayoutManager
import com.exclusivenow.R
import com.exclusivenow.databinding.FragmentSavedArticlesBinding
import com.exclusivenow.model.Article
import com.exclusivenow.model.SavedArticle
import com.exclusivenow.model.toArticle
import com.exclusivenow.viewmodel.SavedArticleViewModel

class SavedArticlesFragment : Fragment(), NewsAdapter.OnItemClickListener, NewsAdapter.OnSaveClickListener {

    private var _binding: FragmentSavedArticlesBinding? = null
    private val binding get() = _binding!!
    private val savedArticleViewModel: SavedArticleViewModel by activityViewModels()
    private lateinit var newsAdapter: NewsAdapter

    private enum class SortOrder {
        NEWEST,
        OLDEST
    }
    private var currentSortOrder: SortOrder = SortOrder.NEWEST


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentSavedArticlesBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        newsAdapter = NewsAdapter(this, this)
        binding.savedArticlesRecyclerView.apply {
            layoutManager = LinearLayoutManager(context)
            adapter = newsAdapter
        }

        binding.sortButton.setOnClickListener {
            showSortingMenu(it)
        }

        binding.clearAllButton.setOnClickListener {
            clearAllSavedArticles()
        }
        updateSortButtonText()
        observeSavedArticles()
    }

    fun refreshData() {
        observeSavedArticles()
    }

    private fun observeSavedArticles() {
        savedArticleViewModel.savedArticles.observe(viewLifecycleOwner) { savedArticles ->
            val sortedArticles = when (currentSortOrder) {
                SortOrder.NEWEST -> savedArticles.sortedByDescending { it.savedAt }
                SortOrder.OLDEST -> savedArticles.sortedBy { it.savedAt }
            }
            updateRecyclerView(sortedArticles)
        }
    }



    private fun updateRecyclerView(savedArticles: List<SavedArticle>) {
        val articleList = savedArticles.map { it.toArticle() }
        val savedUrls = savedArticles.mapNotNull{it.url}
        newsAdapter.setArticles(articleList, savedUrls)

        if (articleList.isEmpty()) {
            binding.noSavedArticlesTextView.visibility = View.VISIBLE
            binding.savedArticlesRecyclerView.visibility = View.GONE
        } else {
            binding.noSavedArticlesTextView.visibility = View.GONE
            binding.savedArticlesRecyclerView.visibility = View.VISIBLE
        }
    }

    private fun showSortingMenu(view: View) {
        val popup = PopupMenu(context, view)
        popup.inflate(R.menu.sort_menu)
        popup.setOnMenuItemClickListener { item ->
            when (item.itemId) {
                R.id.sort_newest -> {
                    currentSortOrder = SortOrder.NEWEST
                    updateSortButtonText()
                    observeSavedArticles()
                    true
                }
                R.id.sort_oldest -> {
                    currentSortOrder = SortOrder.OLDEST
                    updateSortButtonText()
                    observeSavedArticles()
                    true
                }
                else -> false
            }
        }
        popup.show()
    }

    private fun updateSortButtonText() {
        when (currentSortOrder) {
            SortOrder.NEWEST -> binding.sortButton.text = getString(R.string.sort_newest)
            SortOrder.OLDEST -> binding.sortButton.text = getString(R.string.sort_oldest)
        }
    }


    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }

    override fun onItemClick(article: Article) {
        val intent = ArticleDetailActivity.newIntent(requireContext(), article)
        startActivity(intent)
    }
    override fun onSaveClick(article: Article, position: Int) {
    }


    override fun onUnsaveClick(article: Article, position: Int) {
    }

    private fun clearAllSavedArticles() {
        savedArticleViewModel.savedArticles.value?.let{
            for (article in it){
                savedArticleViewModel.deleteSavedArticle(article)
            }
        }
    }
}