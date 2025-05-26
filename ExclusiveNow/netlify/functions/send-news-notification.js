const axios = require('axios');
const OneSignal = require('onesignal-node');

exports.handler = async function (event, context) {
  try {
    // 1. Fetch News from NewsAPI
    const newsResponse = await axios.get('https://newsapi.org/v2/top-headlines', {
      params: {
        apiKey: process.env.NEWS_API_KEY, // Use environment variable for API key
        country: 'us',
      },
    });

    const articles = newsResponse.data.articles;

    // 2. "Major News" Detection (Example)
    for (const article of articles) {
      if (isMajorNews(article)) {
        // 3. Send Push Notification using OneSignal API
        const pushClient = new OneSignal.Client({
          userAuthKey: process.env.ONESIGNAL_USER_AUTH_KEY, // OneSignal User Auth Key
          app: { appAuthKey: process.env.ONESIGNAL_APP_AUTH_KEY, appId: process.env.ONESIGNAL_APP_ID }, // OneSignal App Auth Key and App ID
        });

        const notification = {
          contents: {
            en: article.title, // English message
          },
          headings: {
            en: 'Breaking News!', // English title
          },
          data: {
            articleUrl: article.url, // Custom data
          },
          included_segments: ['All'], // Send to all users
        };

        const response = await pushClient.createNotification(notification);
        console.log('OneSignal notification sent:', response.statusCode, response.body);
      }
    }

    return {
      statusCode: 200,
      body: JSON.stringify({ message: 'Notification check completed' }),
    };
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Notification check failed' }),
    };
  }
};


function isMajorNews(article) {
  // **IMPORTANT:** Implement your own logic here.
  const keywords = ['urgent', 'breaking', 'crisis', 'war', 'attack', 'explosion'];
  const title = article.title.toLowerCase();
  return keywords.some((keyword) => title.includes(keyword));
}