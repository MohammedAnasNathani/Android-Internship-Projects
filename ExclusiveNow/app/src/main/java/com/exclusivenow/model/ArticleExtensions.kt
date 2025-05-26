package com.exclusivenow.model

fun Article.toSavedArticle(): SavedArticle {
    return SavedArticle(
        sourceId = this.source?.id,
        sourceName = this.source?.name,
        author = this.author,
        title = this.title,
        description = this.description,
        url = url,
        urlToImage = urlToImage,
        publishedAt = publishedAt,
        content = content
    )
}