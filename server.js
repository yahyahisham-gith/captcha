require('dotenv').config({ path: './hcaptcha_keys.env' });
require('dotenv').config({ path: './recaptcha_keys.env' });
const express = require('express');
const svgCaptcha = require('svg-captcha');
const path = require('path');
const readline = require('readline');
const axios = require('axios'); 
const helmet = require('helmet');
const morgan = require('morgan');
const fs = require('fs');

const app = express();

const colors = {
    cyan: "\x1b[36m",
    green: "\x1b[32m",
    red: "\x1b[31m",
    yellow: "\x1b[33m",
    reset: "\x1b[0m"
};

// Security and Logging
app.use(helmet({
    contentSecurityPolicy: false, // Disabled to allow cross-domain Captcha scripts
})); 
app.use(morgan('dev')); 
app.use(express.json());

let currentCaptcha = "";

// --- UPDATED APK DOWNLOAD ROUTE ---
app.get('/cdn/apk/download', (req, res) => {
    const cdnDir = path.resolve(__dirname, 'cdn');
    const specificFile = path.join(cdnDir, 'app-debug.apk');

    // 1. Try to find the specific file first
    if (fs.existsSync(specificFile)) {
        console.log(`${colors.green}[CDN] Sending app-debug.apk...${colors.reset}`);
        return res.download(specificFile, 'app-debug.apk');
    }

    // 2. Fallback: Look for ANY .apk file in the folder
    try {
        const files = fs.readdirSync(cdnDir);
        const anyApk = files.find(file => file.endsWith('.apk'));

        if (anyApk) {
            const fallbackPath = path.join(cdnDir, anyApk);
            console.log(`${colors.yellow}[CDN] app-debug.apk missing, sending ${anyApk} instead...${colors.reset}`);
            return res.download(fallbackPath, anyApk);
        }
    } catch (err) {
        console.log(`${colors.red}[!] CDN folder error: ${err.message}${colors.reset}`);
    }

    // 3. Fail gracefully
    console.log(`${colors.red}[!] No APK files found in: ${cdnDir}${colors.reset}`);
    res.status(404).send("Error: No APK file found in the /cdn/ folder.");
});

// Provide site keys to frontend
app.get('/api/config', (req, res) => {
    res.json({
        hSite: process.env.HCAPTCHA_SITE_KEY,
        gSite: process.env.RECAPTCHA_SITE_KEY
    });
});

app.get('/api/solution', (req, res) => {
    res.json({ answer: currentCaptcha });
});

app.get('/api/captcha', (req, res) => {
    res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate');
    const captcha = svgCaptcha.create({ 
        size: 5, 
        noise: 3, 
        color: true, 
        background: '#f1f3f5', // Matches the new light theme
        width: 250, 
        height: 100 
    });
    currentCaptcha = captcha.text;
    res.type('svg');
    res.status(200).send(captcha.data);
});

app.post('/api/verify', async (req, res) => {
    const { input, hCaptchaToken, recaptchaToken } = req.body;
    try {
        const hRes = await axios.post('https://hcaptcha.com/siteverify', new URLSearchParams({
            secret: process.env.HCAPTCHA_SECRET_KEY,
            response: hCaptchaToken
        }));

        const gRes = await axios.post('https://www.google.com/recaptcha/api/siteverify', new URLSearchParams({
            secret: process.env.RECAPTCHA_SECRET_KEY,
            response: recaptchaToken
        }));

        if (hRes.data.success && gRes.data.success) {
            if (input && input.toLowerCase() === currentCaptcha.toLowerCase()) {
                console.log(`${colors.green}[+] VERIFIED: User passed all checks.${colors.reset}`);
                return res.json({ success: true, msg: "VERIFIED" });
            }
            return res.json({ success: false, msg: "IMAGE_CODE_WRONG" });
        }
        res.json({ success: false, msg: "BOT_CHECK_FAILED" });
    } catch (e) {
        res.status(500).json({ success: false, msg: "SERVER_ERROR" });
    }
    // Add this inside your app.post('/api/verify', ...)
const turnstileSecret = process.env.CLOUDFLARE_TURNSTILE_SECRET_KEY;
const turnstileToken = req.body.turnstileToken;

const cfResponse = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', {
    method: 'POST',
    body: JSON.stringify({
        secret: turnstileSecret,
        response: turnstileToken
    }),
    headers: { 'Content-Type': 'application/json' }
});

const cfData = await cfResponse.json();
if (!cfData.success) {
    return res.json({ success: false, msg: "Layer 3 (Turnstile) failed verification." });
}
// Logic to verify the solution
const { altchaToken } = req.body;
const isValidAltcha = await verifySolution(altchaToken, process.env.ALTCHA_HMAC_KEY);

if (!isValidAltcha) {
    return res.json({ success: false, msg: "Altcha PoW verification failed." });
}
});

// GET: Generate Altcha Challenge
app.get('/api/altcha-challenge', async (req, res) => {
    try {
        // HMAC_KEY should be a long random string in your .env
        const challenge = await createChallenge({
            hmacKey: process.env.ALTCHA_HMAC_KEY || 'default_secret_salt_12345',
            maxNumber: 100000, // Complexity (approx 1-2 seconds of work)
            expires: 3600,     // Challenge expires in 1 hour
        });

        res.json(challenge);
    } catch (err) {
        res.status(500).json({ error: 'Failed to generate challenge' });
    }
});

app.get('/', (req, res) => res.sendFile(path.join(__dirname, 'index.html')));

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
rl.question(`${colors.cyan}Port (D for 3000): ${colors.reset}`, (choice) => {
    let port = (choice.toUpperCase() === 'D' || choice === "") ? 3000 : parseInt(choice);
    app.listen(port, () => {
        console.log(`\n${colors.green}====================================`);
        console.log(`[ ONLINE ] http://localhost:${port}`);
        console.log(`[ APK ] Path ready at /cdn/apk/download`);
        console.log(`====================================${colors.reset}`);
    });
    rl.close();
});