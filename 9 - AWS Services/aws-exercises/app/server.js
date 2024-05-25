const express = require('express');
const path = require('path');
const fs = require('fs');
const app = express();

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

app.get('/profile-picture-andrea', (req, res) => {
    const img = fs.readFileSync(path.join(__dirname, 'images/profile-andrea.jpg'));
    res.writeHead(200, { 'Content-Type': 'image/jpeg' });
    res.end(img, 'binary');
});

app.get('/profile-picture-ari', (req, res) => {
    const img = fs.readFileSync(path.join(__dirname, 'images/profile-ari.jpeg'));
    res.writeHead(200, { 'Content-Type': 'image/jpeg' });
    res.end(img, 'binary');
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`App listening on port ${PORT}!`);
});

