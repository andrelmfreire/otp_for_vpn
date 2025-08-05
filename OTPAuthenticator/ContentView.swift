import SwiftUI
import Foundation
import CryptoKit

// Helper to decode QR code and extract secret
func extractSecret(from url: String) -> String? {
    guard let components = URLComponents(string: url),
          let queryItems = components.queryItems else { return nil }
    for item in queryItems {
        if item.name.lowercased() == "secret" {
            return item.value
        }
    }
    return nil
}

// Helper to extract service name from OTP Auth URL
func extractServiceName(from url: String) -> String {
    guard let components = URLComponents(string: url) else { 
        return "Unknown Service" 
    }
    
    // Extract the path component (everything after "otpauth://totp/")
    let path = components.path
    if path.hasPrefix("/") {
        let serviceName = String(path.dropFirst())
        return serviceName.isEmpty ? "Unknown Service" : serviceName
    }
    
    return "Unknown Service"
}

// Base32 decode
func base32DecodeToData(_ base32String: String) -> Data? {
    let base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    let string = base32String.uppercased().replacingOccurrences(of: "=", with: "")
    var bytes = [UInt8]()
    var currentByte: UInt8 = 0
    var bitsRemaining: UInt8 = 8
    for char in string {
        guard let index = base32Alphabet.firstIndex(of: char) else { return nil }
        let value = UInt8(base32Alphabet.distance(from: base32Alphabet.startIndex, to: index))
        if bitsRemaining > 5 {
            currentByte = currentByte | (value << (bitsRemaining - 5))
            bitsRemaining -= 5
        } else {
            currentByte = currentByte | (value >> (5 - bitsRemaining))
            bytes.append(currentByte)
            currentByte = (value << (3 + bitsRemaining)) & 0xFF
            bitsRemaining += 3
        }
    }
    if bitsRemaining < 8 && currentByte != 0 {
        bytes.append(currentByte)
    }
    return Data(bytes)
}

// TOTP generator
func generateTOTP(secret: String, timeInterval: TimeInterval = 30, digits: Int = 6) -> String? {
    guard let keyData = base32DecodeToData(secret) else { return nil }
    let counter = UInt64(Date().timeIntervalSince1970) / UInt64(timeInterval)
    var counterBigEndian = counter.bigEndian
    let counterData = Data(bytes: &counterBigEndian, count: MemoryLayout<UInt64>.size)
    let hash = HMAC<Insecure.SHA1>.authenticationCode(for: counterData, using: SymmetricKey(data: keyData))
    let hashData = Data(hash)
    let offset = Int(hashData.last! & 0x0f)
    
    // Extract 4 bytes manually to avoid alignment issues
    let byte1 = UInt32(hashData[offset])
    let byte2 = UInt32(hashData[offset + 1])
    let byte3 = UInt32(hashData[offset + 2])
    let byte4 = UInt32(hashData[offset + 3])
    
    var code = (byte1 << 24) | (byte2 << 16) | (byte3 << 8) | byte4
    code = code & 0x7fffffff
    code = code % UInt32(pow(10, Float(digits)))
    return String(format: "%0*u", digits, code)
}

struct ContentView: View {
    @StateObject private var settingsManager = SettingsManager()
    @State private var otpCode: String = ""
    @State private var timeRemaining: Int = 30 - Int(Date().timeIntervalSince1970) % 30
    @State private var showCopiedAlert = false
    @State private var showingSettings = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    func updateOTP() {
        let secret = extractSecret(from: settingsManager.otpAuthURL) ?? ""
        if let code = generateTOTP(secret: secret) {
            otpCode = code
        }
        timeRemaining = 30 - Int(Date().timeIntervalSince1970) % 30
    }
    
    func copyToClipboard() {
        let finalPassword = "\(settingsManager.baseString)\(otpCode)"
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(finalPassword, forType: .string)
        
        showCopiedAlert = true
        
        // Play bell sound
        NSSound(named: "Ping")?.play()
        
        // Hide alert after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCopiedAlert = false
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("OTP Authenticator")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            Text(extractServiceName(from: settingsManager.otpAuthURL))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Text(otpCode)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.accentColor, lineWidth: 1)
                    )
                
                Text("Expires in \(timeRemaining) seconds")
                    .font(.headline)
                    .foregroundColor(timeRemaining <= 5 ? .red : .secondary)
            }
            
            Button(action: copyToClipboard) {
                HStack {
                    Image(systemName: "doc.on.clipboard")
                    Text("Copy Password")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            .buttonStyle(BorderedButtonStyle())
            
            if showCopiedAlert {
                Text("✅ Password copied to clipboard!")
                    .foregroundColor(.green)
                    .font(.subheadline)
                    .transition(.opacity)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .onAppear(perform: updateOTP)
        .onReceive(timer) { _ in
            updateOTP()
        }
        .onReceive(settingsManager.$otpAuthURL) { _ in
            updateOTP()
        }
        .animation(.easeInOut(duration: 0.3), value: showCopiedAlert)
        .sheet(isPresented: $showingSettings) {
            SettingsView(settingsManager: settingsManager)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 