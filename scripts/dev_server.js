// Local Development Server for Kisan Mandi Bhav & Crop Doctor API
// Runs without any external dependencies on pure Node.js http module

const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const mandiRatesHandler = require('../api/mandi-rates.js');
const detectDiseaseHandler = require('../api/detect-disease.js');

const PORT = process.env.PORT || 3000;
const PUBLIC_DIR = path.join(__dirname, '..', 'public');

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
};

// Simple Express-like adapter for Vercel Serverless Function signatures
function adaptVercelHandler(handler, req, res, parsedUrl, body) {
  req.query = parsedUrl.query || {};
  req.body = body;

  res.status = function (statusCode) {
    res.statusCode = statusCode;
    return res;
  };

  res.json = function (data) {
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    res.end(JSON.stringify(data));
    return res;
  };

  try {
    return handler(req, res);
  } catch (err) {
    console.error('[Dev Server] Handler error:', err);
    res.statusCode = 500;
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify({ error: err.message }));
  }
}

const server = http.createServer(async (req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;

  // Global CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');

  if (req.method === 'OPTIONS') {
    res.statusCode = 200;
    return res.end();
  }

  // Parse Request Body for POST
  let body = '';
  req.on('data', chunk => {
    body += chunk.toString();
  });

  req.on('end', async () => {
    let parsedBody = {};
    if (body) {
      try {
        parsedBody = JSON.parse(body);
      } catch (_) {
        parsedBody = body;
      }
    }

    // 1. API: /api/mandi-rates
    if (pathname === '/api/mandi-rates' || pathname === '/api/live') {
      return adaptVercelHandler(mandiRatesHandler, req, res, parsedUrl, parsedBody);
    }

    // 2. API: /api/detect-disease
    if (pathname === '/api/detect-disease') {
      return adaptVercelHandler(detectDiseaseHandler, req, res, parsedUrl, parsedBody);
    }

    // 3. Static Files from public/
    let filePath = path.join(PUBLIC_DIR, pathname === '/' ? 'index.html' : pathname);
    if (!fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
      filePath = path.join(PUBLIC_DIR, 'index.html');
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';

    try {
      const content = fs.readFileSync(filePath);
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(content);
    } catch (err) {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('File Not Found');
    }
  });
});

server.listen(PORT, () => {
  console.log(`\n======================================================`);
  console.log(`🌾 Kisan Mandi Bhav & Crop Doctor Dev Server Running!`);
  console.log(`👉 Web Portal: http://localhost:${PORT}`);
  console.log(`👉 Mandi API:  http://localhost:${PORT}/api/mandi-rates`);
  console.log(`👉 Doctor API: http://localhost:${PORT}/api/detect-disease`);
  console.log(`======================================================\n`);
});
