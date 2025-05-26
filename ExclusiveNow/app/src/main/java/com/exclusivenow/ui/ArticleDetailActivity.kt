package com.exclusivenow.ui

import android.content.Context
import android.content.Intent
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.lifecycle.lifecycleScope
import coil.load
import com.exclusivenow.R
import com.exclusivenow.databinding.ActivityArticleDetailBinding
import com.exclusivenow.model.Article
import com.exclusivenow.util.FakeNewsDetector
import kotlinx.coroutines.launch

class ArticleDetailActivity : AppCompatActivity() {

    private lateinit var binding: ActivityArticleDetailBinding

    companion object {
        private const val ARTICLE_EXTRA = "article_extra"

        fun newIntent(context: Context, article: Article): Intent {
            return Intent(context, ArticleDetailActivity::class.java).apply {
                putExtra(ARTICLE_EXTRA, article)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityArticleDetailBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val article = intent.getParcelableExtra<Article>(ARTICLE_EXTRA)
        if (article != null) {
            displayArticleDetails(article)
            calculateAndDisplayAccuracy(article)
        } else {
            finish()
        }
    }
    private fun calculateAndDisplayAccuracy(article: Article) {
        lifecycleScope.launch {
            val accuracyScore = FakeNewsDetector.calculateAccuracyScore(article)

            binding.accuracyBlock.visibility = View.VISIBLE

            val (message, colorResId) = when {
                accuracyScore >= 75 -> Pair(getString(R.string.real), R.color.green)
                else -> Pair(getString(R.string.potentially_fake), R.color.red)
            }
            binding.accuracyMessageTextView.text = message

            val circleDrawable = GradientDrawable()
            circleDrawable.shape = GradientDrawable.OVAL
            circleDrawable.setColor(ContextCompat.getColor(this@ArticleDetailActivity, colorResId))
            binding.accuracyIndicator.setImageDrawable(circleDrawable)

            binding.accuracyTextView.text = getString(R.string.accuracy_score, accuracyScore)
            binding.accuracyTextView.visibility = View.VISIBLE

            val textColor = if (accuracyScore >= 75) {
                ContextCompat.getColor(this@ArticleDetailActivity, R.color.black)
            } else {
                ContextCompat.getColor(this@ArticleDetailActivity, R.color.white)
            }
            binding.accuracyTextView.setTextColor(textColor)
            binding.accuracyMessageTextView.setTextColor(textColor)

            binding.disclaimerTextView.text = getString(R.string.fake_news_disclaimer)
            binding.disclaimerTextView.visibility = View.VISIBLE
        }
    }


    private fun displayArticleDetails(article: Article) {
        binding.detailTitleTextView.text = article.title
        binding.detailSourceTextView.text = article.source?.name ?: "Unknown Source"
        binding.detailAuthorTextView.text = article.author ?: "Unknown Author"
        binding.detailDescriptionTextView.text = article.description
        binding.detailContentTextView.text = article.content
        binding.detailPublishedAtTextView.text = article.publishedAt

        binding.detailImageView.load(article.urlToImage) {
            placeholder(R.drawable.ic_image_placeholder)
            error(R.drawable.ic_image_error)
            crossfade(true)
        }

        binding.readFullArticleButton.setOnClickListener {
            article.url?.let { url ->
                val intent = Intent(Intent.ACTION_VIEW, android.net.Uri.parse(url))
                startActivity(intent)
            }
        }
    }
}