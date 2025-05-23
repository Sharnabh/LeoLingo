import SwiftUI
import LocalAuthentication

struct ParentModeLockScreenView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var passcode = ""
    @State private var isShaking = false
    @State private var shouldNavigateToParentMode = false
    
    // Default code - will be updated from Supabase
    @State private var correctCode = "1234"
    
    private let passcodeLength = 4
    private let buttonSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 70 : 60
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 255/255, green: 248/255, blue: 240/255) // Cream background color
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
                    // Passcode Section
                    VStack(spacing: 20) {
                        Text("Enter Passcode to switch in Parent's Mode")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        
                        // Passcode Dots
                        HStack(spacing: 15) {
                            ForEach(0..<4) { index in
                                Circle()
                                    .stroke(Color.black.opacity(0.3), lineWidth: 1)
                                    .background(
                                        Circle()
                                            .fill(index < passcode.count ? Color.black : Color.white)
                                    )
                                    .frame(width: 15, height: 15)
                            }
                        }
                        .modifier(ShakeEffect(shakes: isShaking ? 2 : 0))
                    }
                    
                    // Number Pad
                    VStack(spacing: 25) {
                        ForEach(0..<3) { row in
                            HStack(spacing: 40) {
                                ForEach(1...3, id: \.self) { col in
                                    let number = row * 3 + col
                                    NumberButton(number: number, size: buttonSize) {
                                        numberTapped(number)
                                    }
                                }
                            }
                        }
                        
                        // Last row with 0 and delete
                        HStack(spacing: 40) {
                            // Empty space for alignment
                            Color.clear
                                .frame(width: buttonSize, height: buttonSize)
                            
                            // 0 button
                            NumberButton(number: 0, size: buttonSize) {
                                numberTapped(0)
                            }
                            
                            // Delete button
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
                
                Spacer()
            }
        }
        .onAppear {
            authenticateWithTouchID()
            fetchPasscode()
        }
        .fullScreenCover(isPresented: $shouldNavigateToParentMode) {
            ParentModeSplitView()
        }
    }
    
    private func numberTapped(_ number: Int) {
        guard passcode.count < passcodeLength else { return }
        
        passcode += String(number)
        
        if passcode.count == passcodeLength {
            verifyPasscode()
        }
    }
    
    private func deleteNumber() {
        guard !passcode.isEmpty else { return }
        passcode.removeLast()
    }
    
    private func verifyPasscode() {
        if passcode == correctCode {
            UserDefaults.standard.isUserLoggedIn = true
            UserDefaults.standard.parentModePasscode = correctCode
            shouldNavigateToParentMode = true
        } else {
            withAnimation(.default) {
                isShaking = true
            }
            
            // Reset shake state and clear passcode
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isShaking = false
                passcode = ""
            }
        }
    }
    
    private func fetchPasscode() {
        Task {
            do {
                if let userId = SupabaseDataController.shared.userId {
                    let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                    correctCode = userData.passcode ?? "1234"
                }
            } catch {
                print("Error fetching user: \(error.localizedDescription)")
            }
        }
    }
    
    private func authenticateWithTouchID() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .touchID:
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                    localizedReason: "Unlock Parent Mode") { success, error in
                    DispatchQueue.main.async {
                        if success {
                            UserDefaults.standard.isUserLoggedIn = true
                            shouldNavigateToParentMode = true
                        }
                    }
                }
            default:
                break
            }
        }
    }
}

// MARK: - Supporting Views and Modifiers
struct NumberButton: View {
    let number: Int
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(number)")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(Color(red: 76/255, green: 141/255, blue: 95/255))
                )
        }
    }
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    init(shakes: Int) {
        animatableData = CGFloat(shakes)
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

struct ParentModeSplitView: View {
    var body: some View {
        Text("Parent Mode")
            .onAppear {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let sceneDelegate = windowScene.delegate as? SceneDelegate {
                    let splitVC = ParentModeSplitViewController()
                    splitVC.modalPresentationStyle = .fullScreen
                    sceneDelegate.window?.rootViewController = splitVC
                }
            }
    }
}

#Preview {
    ParentModeLockScreenView()
} 
