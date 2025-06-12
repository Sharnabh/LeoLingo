import SwiftUI

struct OTPVerificationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var otpCode = ""
    @State private var isVerifying = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var remainingTime = 300 // 5 minutes in seconds
    @State private var timer: Timer?
    
    let email: String
    let otpType: OTPType
    let onVerificationSuccess: () -> Void
    
    private let otpLength = 4
    
    private var buttonSize: CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? 70 : 60
    }
    
    private var creamBackgroundColor: Color {
        Color(red: 255/255, green: 248/255, blue: 240/255)
    }
    
    private var otpSection: some View {
        VStack(spacing: 20) {
            // Title
            Text("Verify Your Email")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            
            // Subtitle
            Text("Enter the 4-digit code sent to\n\(email)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            // OTP Dots
            otpDots
            
            // Timer
            Text(timeString(from: remainingTime))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(remainingTime <= 60 ? .red : .gray)
            
            // Error message
            if showError {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
        }
    }
    
    private var otpDots: some View {
        HStack(spacing: 15) {
            ForEach(0..<4) { index in
                Circle()
                    .stroke(Color.black.opacity(0.3), lineWidth: 1)
                    .background(
                        Circle()
                            .fill(index < otpCode.count ? Color.black : Color.white)
                    )
                    .frame(width: 15, height: 15)
            }
        }
        .modifier(OTPShakeEffect(shakes: showError ? 2 : 0))
    }
    
    private var numberPad: some View {
        VStack(spacing: 25) {
            ForEach(0..<3) { row in
                numberRow(for: row)
            }
            
            lastNumberRow
        }
    }
    
    private func numberRow(for row: Int) -> some View {
        HStack(spacing: 40) {
            ForEach(1...3, id: \.self) { col in
                let number = row * 3 + col
                OTPNumberButton(number: number, size: buttonSize) {
                    numberTapped(number)
                }
            }
        }
    }
    
    private var lastNumberRow: some View {
        HStack(spacing: 40) {
            // Resend button
            resendButton
            
            // 0 button
            OTPNumberButton(number: 0, size: buttonSize) {
                numberTapped(0)
            }
            
            // Delete button
            deleteButton
        }
    }
    
    private var resendButton: some View {
        Button(action: resendOTP) {
            Text("Resend")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(width: buttonSize, height: buttonSize)
                .background(
                    Circle()
                        .fill(Color(red: 76/255, green: 141/255, blue: 95/255).opacity(0.7))
                )
        }
        .disabled(remainingTime > 0)
    }
    
    private var deleteButton: some View {
        Button(action: deleteNumber) {
            Image(systemName: "delete.left.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: buttonSize, height: buttonSize)
                .background(
                    Circle()
                        .fill(Color(red: 76/255, green: 141/255, blue: 95/255))
                )
        }
    }
    
    private var verifyButton: some View {
        Button(action: verifyOTP) {
            HStack {
                if isVerifying {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .rotationEffect(Angle(degrees: isVerifying ? 360 : 0))
                        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isVerifying)
                } else {
                    Text("Verify")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(width: buttonSize, height: buttonSize)
            .background(
                Circle()
                    .fill(Color(red: 76/255, green: 141/255, blue: 95/255))
            )
        }
        .disabled(isVerifying)
    }
    
    private var mainContent: some View {
        VStack {
            // Back Button
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Circle().fill(.white))
                        .shadow(radius: 3)
                }
                .padding(.leading, 20)
                .padding(.top, 20)
                Spacer()
            }
            
            Spacer()
            
            // Main Container
            VStack(spacing: 40) {
                otpSection
                numberPad
                
                // Verify Button
                if otpCode.count == otpLength {
                    verifyButton
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            creamBackgroundColor
                .ignoresSafeArea()
            
            // Decorative Leaves
            Image("BaseBackdrop")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // Main Content
            mainContent
        }
        .onAppear {
            startTimer()
            checkEmailConfiguration()
        }
        .onDisappear {
            stopTimer()
        }
        .navigationBarHidden(true)
    }
    
    private func numberTapped(_ number: Int) {
        guard otpCode.count < otpLength else { return }
        
        otpCode += String(number)
        
        // Auto-verify when 4 digits are entered
        if otpCode.count == otpLength {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                verifyOTP()
            }
        }
    }
    
    private func deleteNumber() {
        guard !otpCode.isEmpty else { return }
        otpCode.removeLast()
        showError = false
    }
    
    private func verifyOTP() {
        isVerifying = true
        showError = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let isValid = OTPService.shared.verifyOTP(otpCode)
            
            if isValid {
                onVerificationSuccess()
            } else {
                showError(message: "Invalid or expired code. Please try again.")
            }
            
            isVerifying = false
        }
    }
    
    private func resendOTP() {
        Task {
            do {
                try await OTPService.shared.sendOTP(to: email, type: otpType)
                DispatchQueue.main.async {
                    remainingTime = 300
                    startTimer()
                    showError(message: "Code resent to your email")
                }
            } catch {
                DispatchQueue.main.async {
                    showError(message: "Failed to resend code. Please try again.")
                }
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
        otpCode = ""
        
        withAnimation(.default) {
            // Trigger shake animation
        }
        
        // Hide error after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showError = false
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func checkEmailConfiguration() {
        if !OTPService.shared.isConfigured() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showError(message: "Email configuration required. Please contact support.")
            }
        }
    }
}

#Preview {
    OTPVerificationView(
        email: "test@example.com",
        otpType: .signup,
        onVerificationSuccess: {}
    )
}
