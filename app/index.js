'use strict';

const express = require('express');
const app = express();

app.use((req, res) => {
    res.status(200).send('Hello, world3!');
});
// Start the server
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
    console.log(`App listening on port ${PORT}`);
    console.log('Press Ctrl+C to quit.');
});
