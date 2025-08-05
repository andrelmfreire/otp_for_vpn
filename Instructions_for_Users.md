# OTP Authenticator - Setup Instructions

## Installation
1. **Download** the `OTP_Authenticator_v1.0.zip` file
2. **Double-click** the zip file to extract it
3. **Move** `OTP Authenticator.app` to your Applications folder (optional)
4. **Double-click** `OTP Authenticator.app` to launch

## First-Time Setup
1. **Click the gear icon** ⚙️ in the top right corner
2. **Enter your information**:
   - **Password**: Your base password (will be combined with the OTP code)
   - **OTP Auth URL**: Your `otpauth://totp/...` URL from your 2FA setup

## Getting Your OTP Auth URL
1. Go to your service's 2FA setup page
2. When shown a QR code, look for "Can't scan?" or "Enter manually"
3. Copy the text that starts with `otpauth://totp/`
4. Paste it in the OTP Auth URL field

## Usage
- The app will show your current OTP code
- Click **"Copy Password"** to copy your complete password (base password + OTP code)
- Codes refresh every 30 seconds
- Your settings are saved automatically

## System Requirements
- macOS 11.0 or later
- Apple Silicon (M1/M2) or Intel Mac

## Notes
- This is a standalone app - no installation required
- Your settings are stored locally and privately
- The app works offline once configured