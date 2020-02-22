function log(message, label) {
  if (label) {
    console.log(label + " : ", message);
  } else {
    console.log(message);
  }
}

module.exports = { log };
