const express = require("express");
const router = express.Router();
const { Form, Question } = require("../models/Form");

router.post("/", async (req, res) => {
  console.log("/api/forms POST request received:", req.body);
  try {
    const newForm = new Form(req.body);
    const savedForm = await newForm.save();
    console.log("Form created:", savedForm);

    res.status(201).json(savedForm);
  } catch (err) {
    console.error("Error creating form:", err);
    res.status(400).json({ message: err.message });
  }
});

router.get("/", async (req, res) => {
  console.log("/api/forms GET request received");
  try {
    const forms = await Form.find();
    console.log("Forms fetched (raw):", forms);
    const plainForms = forms.map((form) => form.toObject());
    console.log("Forms fetched (plain):", plainForms);
    res.json(forms);
  } catch (err) {
    console.error("Error fetching forms:", err);
    res.status(500).json({ message: err.message });
  }
});

router.get("/:id", async (req, res) => {
  console.log(`/api/forms/${req.params.id} GET request received`);
  try {
    const form = await Form.findById(req.params.id);
    if (!form) {
      console.log("Form not found");
      return res.status(404).json({ message: "Form not found" });
    }
    console.log("Form fetched:", form);
    res.json(form);
  } catch (err) {
    console.error("Error fetching form:", err);
    res.status(500).json({ message: err.message });
  }
});

// Get a specific form by shareable ID (Used by the web client to display the form)
router.get("/share/:shareableId", async (req, res) => {
  const shareableId = req.params.shareableId;
  console.log(`/api/forms/share/${shareableId} GET request received`);
  console.log("Fetching form with shareableId:", shareableId);

  try {
    // Find the form by shareableId
    const form = await Form.findOne({ shareableId: shareableId });

    if (!form) {
      console.log("Form not found for shareableId:", shareableId);
      return res.status(404).json({ message: "Form not found" });
    }

    console.log("Form fetched for sharing:", form);

    const formData = {
      title: form.title,
      description: form.description,
      questions: form.questions,
    };

    res.json(formData);
  } catch (err) {
    console.error("Error fetching form for sharing:", err);
    res.status(500).json({ message: err.message });
  }
});

router.patch("/:id", async (req, res) => {
  console.log(`/api/forms/${req.params.id} PATCH request received:`, req.body);
  try {
    const updatedForm = await Form.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
    });
    if (!updatedForm) {
      console.log("Form not found");
      return res.status(404).json({ message: "Form not found" });
    }
    console.log("Form updated:", updatedForm);
    res.json(updatedForm);
  } catch (err) {
    console.error("Error updating form:", err);
    res.status(400).json({ message: err.message });
  }
});

router.delete("/:id", async (req, res) => {
  console.log(`/api/forms/${req.params.id} DELETE request received`);
  try {
    const deletedForm = await Form.findByIdAndDelete(req.params.id);
    if (!deletedForm) {
      console.log("Form not found");
      return res.status(404).json({ message: "Form not found" });
    }
    console.log("Form deleted:", deletedForm);
    res.json({ message: "Form deleted" });
  } catch (err) {
    console.error("Error deleting form:", err);
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
