const puppeteer = require('puppeteer-core');
const path = require('path');
const fs = require('fs');

const CHROME_PATH = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';
const OUT_DIR = path.resolve(__dirname, '..', 'out', 'raw', 'pixel-10-pro');
fs.mkdirSync(OUT_DIR, { recursive: true });

const screens = [
  { id: 'mandi-bhav', url: 'http://localhost:8080/#/mandi', title: 'Mandi Rates' },
  { id: 'weather-radar', url: 'http://localhost:8080/#/mausam', title: 'Mausam Weather' },
  { id: 'ai-crop-doctor', url: 'http://localhost:8080/#/crop-doctor', title: 'AI Crop Doctor' },
  { id: 'govt-schemes', url: 'http://localhost:8080/#/yojna', title: 'Govt Schemes' },
  { id: 'farm-khata', url: 'http://localhost:8080/#/farm-khata', title: 'Farm Khata' },
];

async function capture() {
  console.log('Launching Chrome via puppeteer-core...');
  const browser = await puppeteer.launch({
    executablePath: CHROME_PATH,
    headless: 'new',
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-gpu',
      '--hide-scrollbars',
      '--window-size=430,932',
    ],
  });

  const page = await browser.newPage();
  // Set high-DPI mobile viewport (iPhone 16 Pro Max / Pixel 9 Pro spec: 430x932 @ 3x = 1290x2796)
  await page.setViewport({
    width: 430,
    height: 932,
    deviceScaleFactor: 3,
    isMobile: true,
    hasTouch: true,
  });

  for (const s of screens) {
    console.log(`Navigating to ${s.title} (${s.url})...`);
    await page.goto(s.url, { waitUntil: 'networkidle2', timeout: 30000 });
    // Wait for Flutter Web engine and fonts/data to render
    await new Promise(r => setTimeout(r, 4000));
    
    const filePath = path.join(OUT_DIR, `${s.id}.png`);
    await page.screenshot({ path: filePath, fullPage: false });
    console.log(`Saved real screenshot: ${filePath}`);
  }

  await browser.close();
  console.log('All real app screenshots captured successfully!');
}

capture().catch(err => {
  console.error('Error capturing real screenshots:', err);
  process.exit(1);
});
