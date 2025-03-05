import SwiftUI

struct HumanBodySplashScreen: View {
    @State private var opacity = 0.0
    @Environment(\.presentationMode) var presentationMode // For dismissing the screen

    var body: some View {
        ZStack {
            // ✅ Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 177/255, green: 226/255, blue: 105/255), Color(red: 192/255, green: 130/255, blue: 50/255)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Image("HumanBody") // Ensure this image exists
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
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
