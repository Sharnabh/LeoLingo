import SwiftUI

struct OTPVerificationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var otpCode = ""
    @State private var isShaking = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var remainingTime = 60
    @State private var timer: Timer?
    
    let email: String
    let otpType: OTPType
    let onVerificationSuccess: () -> Void
    
    private let otpLength = 4
    
    private let buttonSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 70 : 60
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 255/255, green: 248/255, blue: 240/255)
                .ignoresSafeArea()
            
            // Decorative Leaves
            Image("BaseBackdrop")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // Main Content
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
                    // OTP Section
                    VStack(spacing: 20) {
                        Text("Verify Your Email")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        
                        Text("Enter the 4-digit code sent to\n\(email)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        // OTP Dots
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
                        .modifier(ShakeEffect(shakes: isShaking ? 2 : 0))
                        
                       
                        
                        // Error message
                        if showError {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Number Pad
                    VStack(spacing: 25) {
                        ForEach(0..<3) { row in
                            HStack(spacing: 40) {
                                ForEach(1...3, id: \.self) { col in
                                    let number = row * 3 + col
                                    OTPNumberButton(number: number, size: buttonSize) {
                                        numberTapped(number)
                                    }
                                }
                            }
                        }
                        
                        // Last row with 0 and delete
                        HStack(spacing: 40) {
                            Color.clear
                                .frame(width: buttonSize, height: buttonSize)
                            
                            OTPNumberButton(number: 0, size: buttonSize) {
                                numberTapped(0)
                            }
                            
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
                    }
                }
                .padding(.vertical, 40)
                .padding(.horizontal, 30)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color(red: 143/255, green: 91/255, blue: 66/255), lineWidth: 3)
                        )
                )
                .padding(.horizontal, 20)
                
                // Resend (plain text with timer)
                HStack(spacing: 4) {
                    if remainingTime > 0 {
                        Text("Resend in")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                        Text(timeString(from: remainingTime))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    } else {
                        Button(action: resendOTP) {
                            Text("Resend")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 76/255, green: 141/255, blue: 95/255))
                                .underline()
                        }
                    }
                }
                .padding(.top, 20)
                
                Spacer()
            }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
        // isVerifying = true
        showError = false
        isShaking = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let isValid = OTPService.shared.verifyOTP(otpCode)
            
            if isValid {
                onVerificationSuccess()
            } else {
                withAnimation(.default) {
                    isShaking = true
                    otpCode = ""
                }
                
                
            }
            // isVerifying = false
        }
    }
    
    private func resendOTP() {
        Task {
            do {
                try await OTPService.shared.sendOTP(to: email, type: otpType)
                DispatchQueue.main.async {
                    remainingTime = 60
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
            isShaking = true
        }
        // Hide error after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isShaking = false
        }
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

//// ShakeEffect (reuse from ParentModeLockScreenView)
//struct ShakeEffect: GeometryEffect {
//    var amount: CGFloat = 10
//    var shakesPerUnit = 3
//    var animatableData: CGFloat
//    
//    init(shakes: Int) {
//        animatableData = CGFloat(shakes)
//    }
//    
//    func effectValue(size: CGSize) -> ProjectionTransform {
//        ProjectionTransform(CGAffineTransform(translationX:
//            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
//            y: 0))
//    }
//}

#Preview {
    OTPVerificationView(
        email: "test@example.com",
        otpType: .signup,
        onVerificationSuccess: {}
    )
}
