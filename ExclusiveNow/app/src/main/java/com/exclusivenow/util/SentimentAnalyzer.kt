package com.exclusivenow.util

object SentimentAnalyzer {

    private val positiveWords = setOf("good", "great", "amazing", "positive", "benefit", "success", "improved", "progress", "strong")
    private val negativeWords = setOf("bad", "terrible", "awful", "negative", "harm", "failure", "decreased", "problem", "weak", "fake", "fraud", "hoax")

    fun analyzeSentiment(text: String?): Sentiment {
        if (text == null) return Sentiment.NEUTRAL

        val words = text.lowercase().split("\\s+".toRegex())
        var positiveCount = 0
        var negativeCount = 0

        for (word in words) {
            if (positiveWords.contains(word)) positiveCount++
            if (negativeWords.contains(word)) negativeCount++
        }

        return when {
            positiveCount > negativeCount -> Sentiment.POSITIVE
            negativeCount > positiveCount -> Sentiment.NEGATIVE
            else -> Sentiment.NEUTRAL
        }
    }

    enum class Sentiment {
        POSITIVE,
        NEGATIVE,
        NEUTRAL
    }
}