import Foundation

struct Account: Identifiable, Codable {
    let id: UUID
    var name: String
    var issuer: String
    var secret: String
    var algorithm: String = "SHA1"
    var digits: Int = 6
    var period: Int = 30
    var basePassword: String = ""
    var useBasePassword: Bool = false
    
    // Computed property for display
    var displayName: String {
        if issuer.isEmpty {
            return name
        } else {
            return "\(issuer) (\(name))"
        }
    }
    
    // Extract secret from otpauth URL
    static func fromOTPAuthURL(_ url: String) -> Account? {
        guard let components = URLComponents(string: url),
              let queryItems = components.queryItems else { return nil }
        
        // Extract secret
        guard let secret = queryItems.first(where: { $0.name.lowercased() == "secret" })?.value else {
            return nil
        }
        
        // Extract account name from path (everything after "otpauth://totp/")
        let path = components.path
        let accountName = path.hasPrefix("/") ? String(path.dropFirst()) : path
        
        // Extract issuer from query parameters or account name
        let issuer = queryItems.first(where: { $0.name.lowercased() == "issuer" })?.value ?? ""
        
        // Extract algorithm
        let algorithm = queryItems.first(where: { $0.name.lowercased() == "algorithm" })?.value?.uppercased() ?? "SHA1"
        
        // Extract digits
        let digits = Int(queryItems.first(where: { $0.name.lowercased() == "digits" })?.value ?? "6") ?? 6
        
        // Extract period
        let period = Int(queryItems.first(where: { $0.name.lowercased() == "period" })?.value ?? "30") ?? 30
        
        return Account(
            id: UUID(),
            name: accountName,
            issuer: issuer,
            secret: secret,
            algorithm: algorithm,
            digits: digits,
            period: period
        )
    }
    
    // Generate OTP for this account
    func generateOTP() -> String? {
        return generateTOTP(secret: secret, timeInterval: TimeInterval(period), digits: digits)
    }
}
