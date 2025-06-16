# LeoLingo OTP Authentication Setup

## Overview
The LeoLingo app now includes OTP (One-Time Password) verification for both login and signup processes using email verification via SwiftSMTP.

## Setup Instructions

### 1. Email Configuration
You need to configure your email credentials in `OTPService.swift`:

```swift
// Replace these with your actual email credentials
private let smtp = SMTP(
    hostname: "smtp.gmail.com",           // Your SMTP server
    email: "your-email@gmail.com",        // Your email address
    password: "your-app-password"         // Your app password (not regular password)
)
```

### 2. Gmail Setup (Recommended)
If using Gmail:
1. Enable 2-Factor Authentication on your Gmail account
2. Generate an App Password:
   - Go to Google Account settings
   - Security → 2-Step Verification → App passwords
   - Generate a new app password for "Mail"
   - Use this app password (not your regular Gmail password)

### 3. Other Email Providers
For other email providers, update the SMTP configuration:
- **Outlook/Hotmail**: `smtp-mail.outlook.com` (port 587)
- **Yahoo**: `smtp.mail.yahoo.com` (port 587 or 465)
- **Custom SMTP**: Use your provider's SMTP settings

## Authentication Flow

### Signup Flow
1. User enters name, email, and password
2. App calls `SupabaseDataController.shared.initiateSignup()`
3. OTP is sent to user's email via `OTPService.shared.sendOTP()`
4. User enters OTP in `OTPVerificationView`
5. App verifies OTP and calls `SupabaseDataController.shared.completeSignup()`
6. User proceeds to questionnaire

### Login Flow
1. User enters email and password
2. App calls `SupabaseDataController.shared.initiateLogin()`
3. OTP is sent to user's email
4. User enters OTP in `OTPVerificationView`
5. App verifies OTP and calls `SupabaseDataController.shared.completeLogin()`
6. User proceeds to home screen

## Security Features
- 4-digit OTP codes
- 5-minute expiration time
- Email verification required for both signup and login
- Secure credential validation before OTP generation
- Automatic OTP cleanup after verification

## Testing
1. Configure email credentials in `OTPService.swift`
2. Test signup flow with a valid email address
3. Check email for OTP code
4. Verify OTP entry and completion flow
5. Test login flow similarly

## Troubleshooting
- Ensure email credentials are correct
- Check spam folder for OTP emails
- Verify SMTP server settings for your email provider
- Test with a simple email first to confirm SMTP configuration
