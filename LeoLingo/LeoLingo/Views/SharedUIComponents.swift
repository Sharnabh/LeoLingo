 import SwiftUI

// MARK: - Shared UI Components for PIN/OTP Input

struct OTPNumberButton: View {
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

struct OTPShakeEffect: GeometryEffect {
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
