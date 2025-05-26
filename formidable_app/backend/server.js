const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const http = require("http");
const socketIo = require("socket.io");
const dotenv = require("dotenv");
dotenv.config();

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});

app.use(cors());
app.use(express.json());

mongoose
  .connect(process.env.MONGODB_URI)
  .then(() => console.log("MongoDB Connected..."))
  .catch((err) => console.log(err));

const { Form, Question } = require("./models/Form");
const Response = require("./models/Response");

const formRoutes = require("./routes/forms");
const responseRoutes = require("./routes/responses");
app.use("/api/forms", formRoutes);
app.use("/api/responses", responseRoutes);

io.on("connection", (socket) => {
  console.log("New client connected with ID:", socket.id);

  socket.on("join-form", (formId) => {
    try {
      socket.join(formId);
      console.log(`Client ${socket.id} joined room ${formId}`);
    } catch (error) {
      console.error(`Error joining room ${formId}:`, error);
    }
  });

  socket.on("form-update", (data) => {
    try {
      console.log(`Form update received for formId ${data.formId}:`, data);
      socket.to(data.formId).emit("form-updated", data);
    } catch (error) {
      console.error(`Error emitting form-update for ${data.formId}:`, error);
    }
  });

  socket.on("disconnect", (reason) => {
    console.log(`Client ${socket.id} disconnected. Reason: $reason`);
    const rooms = Object.keys(socket.rooms);
    if (rooms.length > 1) {
      console.log(`Client ${socket.id} was in rooms:`, rooms);
    }
  });

  socket.on("error", (error) => {
    console.error(`Socket error for client ${socket.id}:`, error);
  });
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, "0.0.0.0", () =>
  console.log(`Server running on port ${PORT}`)
);
