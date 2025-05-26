const mongoose = require("mongoose");
const { generateShareableId } = require("../utils/helpers");

const questionSchema = new mongoose.Schema(
  {
    type: { type: String, required: true },
    title: { type: String, required: true },
    options: [String],
    isRequired: { type: Boolean, default: false },
  },
  { timestamps: true }
);

const formSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    description: String,
    questions: [questionSchema],
    theme: {
      color: String,
      font: String,
      logo: String,
    },
    collaborators: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
    shareableId: { type: String, unique: true, default: generateShareableId },
  },
  { timestamps: true }
);


formSchema.pre("save", function (next) {
  if (!this.shareableId) {
    this.shareableId = generateShareableId();
  }
  next();
});


module.exports = {
  Form: mongoose.model("Form", formSchema),
  Question: mongoose.model("Question", questionSchema), 
};
