package com.exclusivenow.api

import com.exclusivenow.model.NewsResponse
import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.Query

interface NewsApiService {

    @GET("top-headlines")
    suspend fun getTopHeadlines(
        @Query("apiKey") apiKey: String,
        @Query("country") country: String = "us"
    ): Response<NewsResponse>

    @GET("top-headlines")
    suspend fun getCategorizedHeadlines(
        @Query("apiKey") apiKey: String,
        @Query("country") country: String = "us",
        @Query("category") category: String
    ): Response<NewsResponse>
}