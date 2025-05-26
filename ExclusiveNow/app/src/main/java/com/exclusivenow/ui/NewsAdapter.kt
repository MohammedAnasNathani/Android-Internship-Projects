package com.exclusivenow.ui

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import coil.load
import com.exclusivenow.R
import com.exclusivenow.model.Article
import com.google.android.material.floatingactionbutton.FloatingActionButton

class NewsAdapter(
    private val onItemClickListener: OnItemClickListener,
    private val onSaveClickListener: OnSaveClickListener
) : RecyclerView.Adapter<NewsAdapter.NewsViewHolder>() {

    interface OnItemClickListener {
        fun onItemClick(article: Article)
    }

    interface OnSaveClickListener {
        fun onSaveClick(article: Article, position: Int)
        fun onUnsaveClick(article: Article, position: Int)
    }

    private var articles = emptyList<Article>()
    private var savedArticleUrls = listOf<String>()

    fun setArticles(articles: List<Article>, savedUrls: List<String> = emptyList()) {
        this.articles = articles
        this.savedArticleUrls = savedUrls
        notifyDataSetChanged()
    }
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): NewsViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.recyclerview_item_article, parent, false)
        return NewsViewHolder(view)
    }

    override fun onBindViewHolder(holder: NewsViewHolder, position: Int) {
        val article = articles[position]
        val isSaved = savedArticleUrls.contains(article.url)
        holder.bind(article, isSaved)
    }

    override fun onBindViewHolder(holder: NewsViewHolder, position: Int, payloads: List<Any>) {
        if (payloads.isEmpty()) {
            onBindViewHolder(holder, position)
        } else {
            for (payload in payloads) {
                if (payload is Boolean) {
                    holder.updateSaveButton(payload)
                }
            }
        }
    }


    override fun getItemCount(): Int = articles.size

    fun getArticlePosition(article: Article): Int {
        return articles.indexOf(article)
    }

    inner class NewsViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val titleTextView: TextView = itemView.findViewById(R.id.titleTextView)
        private val descriptionTextView: TextView =
            itemView.findViewById(R.id.descriptionTextView)
        private val articleImageView: ImageView = itemView.findViewById(R.id.articleImageView)
        private val saveButton: FloatingActionButton = itemView.findViewById(R.id.saveButton)

        fun bind(article: Article, isSaved: Boolean) {
            titleTextView.text = article.title ?: "No Title"
            descriptionTextView.text = article.description ?: "No Description"

            articleImageView.load(article.urlToImage) {
                placeholder(R.drawable.ic_image_placeholder)
                error(R.drawable.ic_image_error)
                crossfade(true)
            }

            itemView.setOnClickListener {
                onItemClickListener.onItemClick(article)
            }

            updateSaveButton(isSaved)

            saveButton.setOnClickListener {
                if (isSaved) {
                    onSaveClickListener.onUnsaveClick(article, adapterPosition)
                } else {
                    onSaveClickListener.onSaveClick(article, adapterPosition)
                }
            }
        }

        fun updateSaveButton(isSaved: Boolean) {
            if (isSaved) {
                saveButton.setImageResource(R.drawable.ic_bookmark_filled)
            } else {
                saveButton.setImageResource(R.drawable.ic_bookmark_border)
            }
        }
    }
}