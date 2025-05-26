const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

exports.sendBreakingNewsNotifications = functions.pubsub
    .schedule("every 5 minutes") // Adjust schedule as needed
    .onRun(async (context) => {
      try {
      // 1. Fetch News from NewsAPI
        const newsResponse = await axios.get(
            "https://newsapi.org/v2/top-headlines",
            {
              params: {
                apiKey: "YOUR_NEWS_API_KEY", // Replace with API key
                country: "us", // Set the country
                // Add other parameters here
              },
            },
        );

        const articles = newsResponse.data.articles;

        // 2. Implement "Major News" Detection Logic (Example)
        for (const article of articles) {
          if (isMajorNews(article)) {
          // 3. Send Push Notification using FCM Admin SDK
            const message = {
              notification: {
                title: "Breaking News!",
                body: article.title,
              },
              data: {
                articleUrl: article.url,
              },
              topic: "breaking_news", // Send to topic
            };

            await admin.messaging().send(message);
            console.log("Successfully sent message:", message);
          }
        }

        return null; // Successful execution
      } catch (error) {
        console.error("Error sending notifications:", error);
        return null;
      }
    });

/**
 * Determines if an article is considered "major news".
 * @param {object} article - The article object from the NewsAPI.
 * @return {boolean} True if the article is major news, false otherwise.
 */
function isMajorNews(article) {
  // **IMPORTANT:** Implement your own logic here.
  // This is a very basic example using keyword matching.
  const keywords = [
    "urgent",
    "breaking",
    "crisis",
    "war",
    "attack",
    "explosion",
  ];
  const title = article.title.toLowerCase();
  return keywords.some((keyword) => title.includes(keyword));
}
