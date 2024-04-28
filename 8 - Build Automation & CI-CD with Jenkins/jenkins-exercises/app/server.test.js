const request = require('supertest');
const app = require('./server');
const fs = require('fs');
const path = require('path');

describe('Server', () => {
  test('should serve the index.html file', async () => {
    const response = await request(app).get('/');
    expect(response.status).toBe(200);
    expect(response.text).toContain('<h1>List of projects team is working on</h1>');
  });

  test('should serve the profile image for Andrea', async () => {
    const response = await request(app).get('/images/profile-andrea.jpg');
    expect(response.status).toBe(200);
    expect(response.headers['content-type']).toContain('image/jpeg');
  });

  test('should serve the profile image for Ari', async () => {
    const response = await request(app).get('/images/profile-ari.jpeg');
    expect(response.status).toBe(200);
    expect(response.headers['content-type']).toContain('image/jpeg');
  });

  test('should return 404 for non-existent routes', async () => {
    const response = await request(app).get('/non-existent');
    expect(response.status).toBe(404);
  });

  test('should return 404 for non-existent image files', async () => {
    const response = await request(app).get('/images/non-existent.jpg');
    expect(response.status).toBe(404);
  });

  test('index.html file should exist', () => {
    const filePath = path.join(__dirname, 'index.html');
    expect(fs.existsSync(filePath)).toBe(true);
  });

  test('profile images should exist', () => {
    const andreaImagePath = path.join(__dirname, 'images', 'profile-andrea.jpg');
    const ariImagePath = path.join(__dirname, 'images', 'profile-ari.jpeg');
    expect(fs.existsSync(andreaImagePath)).toBe(true);
    expect(fs.existsSync(ariImagePath)).toBe(true);
  });
});