const { customAlphabet } = require("nanoid");

const generateShareableId = customAlphabet(
  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_",
  10
);

module.exports = {
  generateShareableId,
};
