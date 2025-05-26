const mongoose = require("mongoose");
require("dotenv").config();

async function connectToMongo() {
  try {
    console.log("Connecting to:", process.env.MONGODB_URI);
    await mongoose.connect(process.env.MONGODB_URI);
    console.log("MongoDB Connected Successfully!");
  } catch (error) {
    console.error("MongoDB Connection Error:", error);
  }
}

connectToMongo();
