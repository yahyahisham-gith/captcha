const express = require('express');
const svgCaptcha = require('svg-captcha');
const pngCaptcha = require('png-captcha');
const readline = require('readline');
const path = require('path');

const app = express();

// --- ASSETS & DOWNLOADS ---
app.use('/cdn', express.static(path.join(__dirname, 'cdn')));

app.get('/cdn/apk', (req, res) => {
    const apkFile = path.join(__dirname, 'cdn', 'app-debug.apk');
    res.download(apkFile, 'app-debug.apk', (err) => {
        if (err) res.status(404).send("ERR_FILE_MISSING");
    });
});

app.use((req, res, next) => {
    res.setHeader('Access-Control-Allow-Origin', '*'); 
    next();
});

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// --- CAPTCHA GENERATOR (PNG=B&W, SVG=COLOR) ---
app.get('/api/captcha', async (req, res) => {
    const mode = req.query.mode || 'svg';
    res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate');

    try {
        if (mode === 'svg') {
            // SVG Mode: Strictly Color
            const captcha = svgCaptcha.create({
                size: 5,
                noise: 3,
                color: true, 
                background: '#f0f0f0',
                width: 250,
                height: 100
            });
            res.type('svg');
            return res.status(200).send(captcha.data);
        } else {
            // PNG Mode: Strictly Black & White
            const generate = (typeof pngCaptcha === 'function') ? pngCaptcha : pngCaptcha.create;
            const captchaBuffer = generate({
                size: 5,
                width: 250,
                height: 100,
                noise: 1,
                color: false, // Force B&W
                background: '#ffffff' 
            });
            res.type('png');
            return res.status(200).send(captchaBuffer);
        }
    } catch (err) {
        console.error("[ CRITICAL_ERROR ]", err.message);
        res.status(500).send("SIGNAL_LOST");
    }
});

rl.question('PORT (D for 3000): ', (choice) => {
    let port = (choice.toUpperCase() === 'D' || choice === "") ? 3000 : parseInt(choice);
    app.listen(port, () => {
        console.log(`\n[ MONITOR_ACTIVE ] Initialized on port: ${port}`);
    });
    rl.close();
});