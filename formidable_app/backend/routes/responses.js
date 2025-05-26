const express = require("express");
const router = express.Router();
const Response = require("../models/Response");
const { Form } = require("../models/Form");

router.post("/", async (req, res) => {
  console.log("/api/responses POST request received:", req.body);
  try {
    const { shareableId, answers, name, email } = req.body;

    const form = await Form.findOne({ shareableId: shareableId }).populate(
      "questions"
    );
    if (!form) {
      console.log("Form not found");
      return res.status(404).json({ message: "Form not found" });
    }

    if (!Array.isArray(answers)) {
      console.log("Answers must be an array");
      return res.status(400).json({ message: "Answers must be an array" });
    }

    if (!name || !email) {
      console.log("Name and email are required");
      return res.status(400).json({ message: "Name and email are required" });
    }

    const formQuestions = form.questions;
    const mappedAnswers = answers
      .map((answer) => {
        const question = formQuestions.find(
          (q) => q.title === answer.questionId
        );
        if (question) {
          return {
            questionId: question._id,
            value: answer.value,
          };
        }
        return null;
      })
      .filter((answer) => answer !== null);

    const newResponse = new Response({
      formId: form._id,
      answers: mappedAnswers,
      name: name,
      email: email,
    });

    const savedResponse = await newResponse.save();
    console.log("Response saved:", savedResponse);

    res.status(201).json(savedResponse);
  } catch (err) {
    console.error("Error submitting response:", err);
    res.status(400).json({ message: err.message });
  }
});

router.get("/form/:formId", async (req, res) => {
  console.log(`/api/responses/form/${req.params.formId} GET request received`);
  try {
    const responses = await Response.find({ formId: req.params.formId });
    console.log("Responses fetched:", responses);
    res.json(responses);
  } catch (err) {
    console.error("Error fetching responses:", err);
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
