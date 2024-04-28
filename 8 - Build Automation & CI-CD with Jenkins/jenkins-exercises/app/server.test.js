const path = require('path');
const fs = require('fs');
const request = require('supertest');
const app = require('./server');

test('main index.html file exists', () => {
  const filePath = path.join(__dirname, 'index.html');
  expect(fs.existsSync(filePath)).toBeTruthy();
});

test('should serve the index.html file', async () => {
  const response = await request(app).get('/');
  expect(response.status).toBe(200);
  expect(response.text).toContain('<h1>List of projects team is working on</h1>');
});

test('should serve the profile image for Andrea', async () => {
  const response = await request(app).get('/profile-picture-andrea');
  expect(response.status).toBe(200);
  expect(response.headers['content-type']).toContain('image/jpg');
});

test('should serve the profile image for Ari', async () => {
  const response = await request(app).get('/profile-picture-ari');
  expect(response.status).toBe(200);
  expect(response.headers['content-type']).toContain('image/jpg');
});