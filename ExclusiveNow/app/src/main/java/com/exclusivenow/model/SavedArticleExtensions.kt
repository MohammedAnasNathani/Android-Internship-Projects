package com.exclusivenow.model

fun SavedArticle.toArticle(): Article {
    return Article(
        source = Source(sourceId, sourceName),
        author = author,
        title = title,
        description = description,
        url = url,
        urlToImage = urlToImage,
        publishedAt = publishedAt,
        content = content
    )
}