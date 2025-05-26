package com.exclusivenow.util

import kotlin.math.exp

object FakeNewsDetector {

    private val reliableSources = setOf(
        "Reuters", "Associated Press", "BBC News", "The New York Times", "The Wall Street Journal",
        "The Guardian", "NPR", "PBS NewsHour", "Bloomberg", "CNN", "Al Jazeera English", "The Washington Post"
    )

    private val unreliableSources = setOf(
        "InfoWars", "Breitbart News", "The Daily Caller", "Natural News", "World News Daily Report"
    )

    private const val RELIABLE_SOURCE_POINTS = 30
    private const val UNRELIABLE_SOURCE_POINTS = -50
    private const val POSITIVE_SENTIMENT_POINTS = 5
    private const val NEUTRAL_SENTIMENT_POINTS = 0
    private const val NEGATIVE_SENTIMENT_POINTS = -10
    private const val EXTERNAL_API_RELIABLE_POINTS = 60
    private const val EXTERNAL_API_UNRELIABLE_POINTS = -70

    suspend fun calculateAccuracyScore(article: com.exclusivenow.model.Article): Int {
        var score = 0

        val sourceName = article.source?.name
        if (isSourceReliable(sourceName)) {
            score += RELIABLE_SOURCE_POINTS
        } else if (isSourceUnreliable(sourceName)) {
            score += UNRELIABLE_SOURCE_POINTS
        }

        when (SentimentAnalyzer.analyzeSentiment(article.title)) {
            SentimentAnalyzer.Sentiment.POSITIVE -> score += POSITIVE_SENTIMENT_POINTS
            SentimentAnalyzer.Sentiment.NEUTRAL -> score += NEUTRAL_SENTIMENT_POINTS
            SentimentAnalyzer.Sentiment.NEGATIVE -> score += NEGATIVE_SENTIMENT_POINTS
        }

        when (SentimentAnalyzer.analyzeSentiment(article.description)) {
            SentimentAnalyzer.Sentiment.POSITIVE -> score += POSITIVE_SENTIMENT_POINTS
            SentimentAnalyzer.Sentiment.NEUTRAL -> score += NEUTRAL_SENTIMENT_POINTS
            SentimentAnalyzer.Sentiment.NEGATIVE -> score += NEGATIVE_SENTIMENT_POINTS
        }


        val claim = "${article.title} ${article.description}"
        val factCheckResult = checkClaim(claim)
        if (factCheckResult.hasFalseClaims) {
            score += EXTERNAL_API_UNRELIABLE_POINTS
        } else {
            score += EXTERNAL_API_RELIABLE_POINTS
        }


        val normalizedScore = (1 / (1 + exp(-score / 50.0))) * 100
        return normalizedScore.toInt().coerceIn(0, 100)
    }


    fun isSourceReliable(sourceName: String?): Boolean {
        return sourceName != null && reliableSources.contains(sourceName)
    }

    fun isSourceUnreliable(sourceName: String?): Boolean {
        return sourceName != null && unreliableSources.contains(sourceName)
    }

    suspend fun checkClaim(claim: String): FactCheckResult {
        return FactCheckResult(false, null)
    }

    data class FactCheckResult(
        val hasFalseClaims: Boolean,
        val detailsUrl: String?
    )
}