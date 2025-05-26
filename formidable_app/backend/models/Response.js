const mongoose = require("mongoose");

const answerSchema = new mongoose.Schema(
  {
    questionId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      ref: "Question",
    },
    value: mongoose.Schema.Types.Mixed,
  },
  { timestamps: true }
);

const responseSchema = new mongoose.Schema(
  {
    formId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Form",
      required: true,
    },
    answers: [answerSchema],
    name: { type: String, required: true },
    email: { type: String, required: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Response", responseSchema);
