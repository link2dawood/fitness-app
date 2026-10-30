// Usage: node tool/extract_men_reference.cjs <reference.mp4>
// Requires Playwright and an installed Chrome. Source footage is user supplied.
const { chromium } = require('playwright');
const fs = require('node:fs');
const { pathToFileURL } = require('node:url');
const path = require('node:path');
const clips = [
  ['mountain_climber_timed', 14, 13, 16.6],
  ['squats', 15, 23.5, 27.1],
  ['high_stepping', 16, 48, 49.65],
  ['reverse_crunches', 17, 33, 35.6],
  ['push_ups', 18, 36.5, 38.85],
  ['plank', 19, 40, 42.6],
  ['cobra_stretch', 20, 61, 63],
];
(async () => {
  if (!process.argv[2]) throw new Error('Supply the reference MP4 path.');
  const browser = await chromium.launch({
    executablePath: process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe',
    headless: true, args: ['--allow-file-access-from-files'],
  });
  try {
    const page = await browser.newPage();
    await page.goto(pathToFileURL(path.resolve(process.argv[2])).href);
    await page.waitForFunction(() => document.querySelector('video')?.readyState >= 2);
    await page.evaluate(() => document.querySelector('video').pause());
    for (const [id, atlas, start, end] of clips) {
      if (process.argv[3] && !process.argv[3].split(',').includes(id)) continue;
      const data = await page.evaluate(async ({start, end}) => {
        const video = document.querySelector('video');
        const canvas = document.createElement('canvas');
        canvas.width = 2560; canvas.height = 912;
        const ctx = canvas.getContext('2d');
        for (let frame = 0; frame < 32; frame++) {
          const presented = new Promise(resolve => video.requestVideoFrameCallback(resolve));
          const sought = new Promise(resolve => video.addEventListener('seeked', resolve, {once: true}));
          video.currentTime = start + (end - start) * frame / 32;
          await Promise.all([sought, presented]);
          // Only the demonstration: exclude the source app's labels and controls.
          ctx.drawImage(video, 24, 156, 432, 308,
            frame % 8 * 320, Math.floor(frame / 8) * 228, 320, 228);
        }
        return canvas.toDataURL('image/png').split(',')[1];
      }, {start, end});
      fs.writeFileSync(`assets/images/challenge_avatars/atlas_${atlas}.png`, Buffer.from(data, 'base64'));
      console.log(`${id}: atlas_${atlas}.png`);
    }
  } finally { await browser.close(); }
})();
