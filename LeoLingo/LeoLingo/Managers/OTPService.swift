import Foundation
import SwiftSMTP

enum OTPType {
    case signup
    case login
}

class OTPService {
    static let shared = OTPService()
    
    private var currentOTP: String?
    private var otpExpiration: Date?
    private let otpValidityDuration: TimeInterval = 60 // 1 minute
    
    // Configuration - Update these with your email settings
    private struct EmailConfig {
        static let smtpHost = "smtp.gmail.com"
        static let smtpPort: Int32 = 587
        static let fromEmail = "sharnabhbanerjee3@gmail.com" // Replace with your email
        static let fromPassword = "jltf plkm ordx yzdw" // Replace with your app password
        static let fromName = "Leo Lingo"
    }
    
    private init() {}
    
    // Email configuration - replace with your actual email credentials
    private lazy var smtp = SMTP(
        hostname: EmailConfig.smtpHost,
        email: EmailConfig.fromEmail,
        password: EmailConfig.fromPassword,
        port: EmailConfig.smtpPort,
        tlsMode: .requireSTARTTLS,
        tlsConfiguration: nil,
        authMethods: [],
        domainName: "localhost",
        timeout: 10
    )
    
    func sendOTP(to email: String, type: OTPType) async throws {
        let otp = generateOTP()
        currentOTP = otp
        otpExpiration = Date().addingTimeInterval(otpValidityDuration)
        
        let subject: String
        let messageText: String
        
        switch type {
        case .signup:
            subject = "LeoLingo - Verify Your Account"
            messageText = """
            Welcome to LeoLingo!
            
            Your verification code is: \(otp)
            
            This code will expire in 1 minute.
            
            If you didn't request this verification, please ignore this email.
            
            Best regards,
            The LeoLingo Team
            """
        case .login:
            subject = "LeoLingo - Login Verification"
            messageText = """
            LeoLingo Login Verification
            
            Your verification code is: \(otp)
            
            This code will expire in 1 minute.
            
            If you didn't request this login, please secure your account immediately.
            
            Best regards,
            The LeoLingo Team
            """
        }
        
        let mail = Mail(
            from: Mail.User(name: EmailConfig.fromName, email: EmailConfig.fromEmail),
            to: [Mail.User(email: email)],
            subject: subject,
            text: messageText
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            smtp.send(mail) { (error) in
                if let error = error {
                    print("Failed to send OTP email: \(error)")
                    continuation.resume(throwing: error)
                } else {
                    print("OTP email sent successfully to \(email)")
                    continuation.resume()
                }
            }
        }
    }
    
    func verifyOTP(_ enteredOTP: String) -> Bool {
        guard let currentOTP = currentOTP,
              let expiration = otpExpiration,
              Date() < expiration else {
            // OTP expired or doesn't exist
            clearOTP()
            return false
        }
        
        let isValid = enteredOTP == currentOTP
        if isValid {
            clearOTP() // Clear OTP after successful verification
        }
        
        return isValid
    }
    
    func isOTPExpired() -> Bool {
        guard let expiration = otpExpiration else { return true }
        return Date() >= expiration
    }
    
    func getRemainingTime() -> TimeInterval? {
        guard let expiration = otpExpiration else { return nil }
        let remaining = expiration.timeIntervalSince(Date())
        return remaining > 0 ? remaining : 0
    }
    
    private func generateOTP() -> String {
        return String(format: "%04d", Int.random(in: 1000...9999))
    }
    
    private func clearOTP() {
        currentOTP = nil
        otpExpiration = nil
    }
    
    // MARK: - Debug and Test Methods
    
    /// Test email configuration by sending a simple test email
    func testEmailConfiguration(to email: String) async throws {
        let testMail = Mail(
            from: Mail.User(name: EmailConfig.fromName, email: EmailConfig.fromEmail),
            to: [Mail.User(email: email)],
            subject: "LeoLingo - Email Configuration Test",
            text: "This is a test email to verify your LeoLingo email configuration is working correctly."
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            smtp.send(testMail) { (error) in
                if let error = error {
                    print("Test email failed: \(error)")
                    continuation.resume(throwing: error)
                } else {
                    print("Test email sent successfully to \(email)")
                    continuation.resume()
                }
            }
        }
    }
    
    /// Get current OTP for debugging (use only in development)
    func getCurrentOTP() -> String? {
        #if DEBUG
        return currentOTP
        #else
        return nil
        #endif
    }
    
    /// Check if email configuration is set up
    func isConfigured() -> Bool {
        return EmailConfig.fromEmail != "your-email@gmail.com" && 
               EmailConfig.fromPassword != "your-app-password"
    }
}
