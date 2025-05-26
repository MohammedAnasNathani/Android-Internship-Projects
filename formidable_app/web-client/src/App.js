import React, { useState, useEffect } from "react";
import axios from "axios";
import { useParams, Route, Routes } from "react-router-dom";
import "./index.css";

const API_BASE_URL = "http://localhost:5000/api";

function FormComponent() {
  const [form, setForm] = useState(null);
  const [formData, setFormData] = useState({});
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showSuccess, setShowSuccess] = useState(false);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");

  const { shareableId } = useParams();

  useEffect(() => {
    const fetchForm = async () => {
      try {
        const response = await axios.get(
          `${API_BASE_URL}/forms/share/${shareableId}`
        );
        setForm(response.data);
        const initialFormData = {};
        response.data.questions.forEach((question) => {
          initialFormData[question.title] =
            question.type === "checkboxes" ? [] : "";
        });
        setFormData(initialFormData);
      } catch (err) {
        setError("Error fetching form");
        console.error(err);
      } finally {
        setIsLoading(false);
      }
    };

    fetchForm();
  }, [shareableId]);

  const handleInputChange = (questionTitle, value) => {
    setFormData({ ...formData, [questionTitle]: value });
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    try {
      const answers = Object.entries(formData).map(([questionId, value]) => ({
        questionId,
        value: value,
      }));

      const response = await axios.post(`${API_BASE_URL}/responses`, {
        shareableId: shareableId,
        answers: answers,
        name: name,
        email: email,
      });

      console.log("Response submitted:", response.data);
      setShowSuccess(true);
      setFormData({});
      setName("");
      setEmail("");

      setTimeout(() => {
        setShowSuccess(false);
      }, 5000);
    } catch (err) {
      console.error("Error submitting form:", err);
      setError("Error submitting form");
    }
  };

  if (isLoading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>Error: {error}</div>;
  }

  return (
    <div className="form-container">
      <h1>{form.title}</h1>
      <p>{form.description}</p>

      {showSuccess && (
        <div className="success-message">Form submitted successfully!</div>
      )}
      {error && <div className="error-message">Error: {error}</div>}

      <form onSubmit={handleSubmit}>
        <div>
          <label htmlFor="name">Your Name*:</label>
          <input
            type="text"
            id="name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            required
          />
        </div>
        <div>
          <label htmlFor="email">Your Email*:</label>
          <input
            type="email"
            id="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
        </div>

        {form.questions.map((question) => (
          <div key={question.title} className="question">
            <label>
              {question.title}
              {question.isRequired && <span>*</span>}
              {question.type === "text" && (
                <input
                  type="text"
                  value={formData[question.title] || ""}
                  onChange={(e) =>
                    handleInputChange(question.title, e.target.value)
                  }
                  required={question.isRequired}
                />
              )}
              {question.type === "long-text" && (
                <textarea
                  value={formData[question.title] || ""}
                  onChange={(e) =>
                    handleInputChange(question.title, e.target.value)
                  }
                  required={question.isRequired}
                />
              )}
              {question.type === "multiple-choice" && (
                <div className="radio-group">
                  {question.options.map((option) => (
                    <label key={option}>
                      <input
                        type="radio"
                        id={`${question.title}-${option}`}
                        name={question.title}
                        value={option}
                        checked={formData[question.title] === option}
                        onChange={(e) =>
                          handleInputChange(question.title, e.target.value)
                        }
                        required={question.isRequired}
                      />
                      {option}
                    </label>
                  ))}
                </div>
              )}
              {question.type === "checkboxes" && (
                <div className="checkbox-group">
                  {question.options.map((option) => (
                    <label key={option}>
                      <input
                        type="checkbox"
                        id={`${question.title}-${option}`}
                        name={question.title}
                        value={option}
                        checked={(formData[question.title] || []).includes(
                          option
                        )}
                        onChange={(e) => {
                          const currentValue = formData[question.title] || [];
                          const updatedValue = e.target.checked
                            ? [...currentValue, option]
                            : currentValue.filter((val) => val !== option);
                          handleInputChange(question.title, updatedValue);
                        }}
                        required={question.isRequired}
                      />
                      {option}
                    </label>
                  ))}
                </div>
              )}

              {question.type === "dropdown" && (
                <select
                  value={formData[question.title] || ""}
                  onChange={(e) =>
                    handleInputChange(question.title, e.target.value)
                  }
                  required={question.isRequired}
                >
                  <option value="" disabled>
                    Select an option
                  </option>
                  {question.options.map((option) => (
                    <option key={option} value={option}>
                      {option}
                    </option>
                  ))}
                </select>
              )}
            </label>
          </div>
        ))}
        <button type="submit">Submit</button>
      </form>
    </div>
  );
}

function App() {
  return (
    <Routes>
      <Route path="/form/share/:shareableId" element={<FormComponent />} />
    </Routes>
  );
}

export default App;
