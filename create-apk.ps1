Write-Host "--- APK BUILD SYSTEM ---" -ForegroundColor Cyan

# 1. Setup Web Directory
if (!(Test-Path "www")) { New-Item -ItemType Directory -Path "www" }
Copy-Item "index.html" -Destination "www\index.html"

# 2. Install Capacitor Core & CLI
Write-Host "[ 1/4 ] Installing Dependencies..." -ForegroundColor Yellow
npm install @capacitor/core @capacitor/cli @capacitor/android

# 3. Initialize Project
Write-Host "[ 2/4 ] Initializing Capacitor..." -ForegroundColor Yellow
npx cap init "JDM_Recovery" "com.jdm.recovery" --web-dir www

# 4. Add Android Platform
Write-Host "[ 3/4 ] Adding Android Platform..." -ForegroundColor Yellow
npx cap add android

# 5. Syncing Files
Write-Host "[ 4/4 ] Syncing Project..." -ForegroundColor Yellow
npx cap copy

Write-Host "`n[ SUCCESS ] Android project is ready." -ForegroundColor Green
Write-Host "[ NEXT STEP ] Run 'npx cap open android' to open in Android Studio and click Build > Build APK." -ForegroundColor Cyan