const express = require('express');

// Constants
const PORT = 8080

// app
const app = express();
app.use(express.json());

app.listen(PORT);
console.log(`Server listening on port: ${PORT}`);

module.exports = app;