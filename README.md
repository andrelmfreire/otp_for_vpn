# OTP for VPN

A native macOS SwiftUI application for generating Time-based One-Time Passwords (TOTP) for VPN authentication, specifically designed for OPNsense integration.

## Features

- ✅ **Native macOS App** - Built with SwiftUI for modern macOS
- ✅ **OPNsense Integration** - Configured for OPNsense TOTP authentication
- ✅ **Auto-refresh** - Updates every 30 seconds automatically
- ✅ **Password Generation** - Combines base password with OTP code
- ✅ **Clipboard Integration** - One-click copy with sound confirmation
- ✅ **Visual Timer** - Shows remaining time (red when < 5 seconds)
- ✅ **RFC 6238 Compliant** - Standard TOTP implementation

## Screenshots

The app displays:
- **OPNsense Authenticator** title
- **Account name** (your service account)
- **Large 6-digit OTP code** in monospace font
- **Countdown timer** with visual feedback
- **Copy Password button** with clipboard icon

## Installation

### Option 1: Download Release
1. Download the latest `.app` from [Releases](../../releases)
2. Move to `/Applications/`
3. Double-click to run

### Option 2: Build from Source
```bash
# Clone the repository
git clone https://github.com/yourusername/otp_for_vpn.git
cd otp_for_vpn

# Build and run
swift run

# Or build app bundle
swift build -c release
```

### Option 3: Xcode
1. Open `Package.swift` in Xcode
2. Press ⌘R to build and run
3. Product → Archive to create distributable app

## Usage

1. Launch the **OTP Authenticator** app
2. The app will display the current 6-digit OTP code
3. Click **"Copy Password"** to copy the full password to clipboard
   - Format: `[Your Password][OTP Code]` (where OTP Code is the 6-digit code)
4. A bell sound confirms the password is copied
5. The code refreshes automatically every 30 seconds

## Configuration

The app is pre-configured with:
- **Secret**: `RGKFLVKQL4JLZROYKWVV4EWTKQJBLCXO`
- **Account**: `your-account@service`
- **Issuer**: OPNsense
- **Algorithm**: SHA-1 (RFC 6238 standard)
- **Digits**: 6
- **Period**: 30 seconds

To modify the configuration, update the `otpAuthURL` variable in `ContentView.swift`:
```swift
let otpAuthURL = "otpauth://totp/your-account@service?secret=YOUR_SECRET_HERE"
```

## Technical Details

### TOTP Implementation
- **Base32 decoding** for secret key processing
- **HMAC-SHA1** authentication code generation
- **Time-based counter** (Unix timestamp / 30)
- **Dynamic truncation** as per RFC 6238
- **6-digit output** with zero-padding

### Dependencies
- **SwiftUI** - Modern UI framework
- **Foundation** - Core system functionality  
- **CryptoKit** - Cryptographic operations

### System Requirements
- **macOS 11.0+** (Big Sur or later)
- **Swift 5.9+** for building from source

## File Structure

```
otp_for_vpn/
├── Package.swift                 # Swift Package Manager configuration
├── OTPAuthenticator/
│   ├── OTPAuthenticatorApp.swift # Main app entry point
│   └── ContentView.swift         # UI and TOTP logic
├── .gitignore                    # Git ignore rules
└── README.md                     # This file
```

## Security Notes

⚠️ **Important**: This repository contains a hardcoded TOTP secret for demo purposes. In production:

1. **Never commit secrets** to version control
2. **Use secure storage** (Keychain, environment variables)
3. **Rotate secrets regularly**
4. **Limit repository access**

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly
5. Commit changes (`git commit -m 'Add amazing feature'`)
6. Push to branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

This project is open source. Feel free to use, modify, and distribute.

## Support

For issues or questions:
1. Check existing [Issues](../../issues)
2. Create a new issue with detailed description
3. Include macOS version and error messages

---

**Note**: This app generates the same TOTP codes as Google Authenticator and other RFC 6238 compliant authenticators when configured with the same secret. 