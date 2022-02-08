/**
 * @param {String} tokenURI "data:application/json;base64,XXXXXX"
 * @returns {Object} {
 *      description: "Congratulation on your successful completion of 30-Web3!!!"
 *      image: "data:image/svg+xml;base64,XXXXX"
 *      name: "30-Web3"
 * }
 */
const parseTokenURI = tokenURI => {
  // Remove the heading part ("data:application/json;base64,")
  const content = tokenURI.substring(29, tokenURI.length - 1);
  // Decode
  const decoded = Buffer.from(content, "base64");
  // Somethimes the closing bracket disappears... Don't know why
  let asString = decoded.toString();
  if (asString[asString.length - 1] !== "}") {
    asString += "}";
  }
  // Parse
  const parsed = JSON.parse(asString);
  return parsed;
};

export default parseTokenURI;
