import SwiftUI

struct HumanBodySplashScreen: View {
    @State private var opacity = 0.0
    @Environment(\.presentationMode) var presentationMode // For dismissing the screen

    var body: some View {
        ZStack {
            // ✅ Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.brown.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Image("HumanBody") // Ensure this image exists
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .opacity(opacity)
                    .shadow(radius: 5)
                    .animation(.easeIn(duration: 1.0), value: opacity)

                Text("Explore Human Body")
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .opacity(opacity)
                    .animation(.easeIn(duration: 1.5), value: opacity)
            }
        }
        .onAppear {
            withAnimation {
                opacity = 1.0
            }
            // Dismiss the splash screen after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
