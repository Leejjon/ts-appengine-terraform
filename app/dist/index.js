import express from 'express';
const app = express();
const port = process.env.PORT || 8080;
app.get('/', (req, res) => {
    res.send('Hello world10!');
});
app.listen(port, function () {
    console.log(`App is listening on port ${port} !`);
});
