import SwiftUI

struct OnboardingSlide: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String? // Optional asset image name
    let systemImageName: String // Fallback system image
    let gradientColors: [Color]
    let accentColor: Color
}

struct OnboardingCarouselView: View {
    let onFinish: () -> Void
    
    @State private var selectedTab = 0
    @State private var animateIllustration = false
    
    private let slides = [
        OnboardingSlide(
            title: "Welcome to LeoLingo!",
            description: "A fun and interactive way for children to learn and speak with confidence.",
            imageName: "LeoLingoMainImage",
            systemImageName: "character.book.closed.fill",
            gradientColors: [Color(hex: "FFF9F2"), Color(hex: "FFEBD6")],
            accentColor: Color(hex: "FF7B3D")
        ),
        OnboardingSlide(
            title: "Interactive Vocal Coach",
            description: "Kids practice speaking and pronouncing words, receiving instant, friendly audio guidance and feedback.",
            imageName: nil,
            systemImageName: "waveform.and.mic",
            gradientColors: [Color(hex: "F3FAF3"), Color(hex: "E2F3E3")],
            accentColor: Color(hex: "4CAF50")
        ),
        OnboardingSlide(
            title: "Fun Learning Games",
            description: "Play interactive activities like Jungle Run and learn vocabulary words through educational flashcards.",
            imageName: nil,
            systemImageName: "gamecontroller.fill",
            gradientColors: [Color(hex: "FFFDF0"), Color(hex: "FFF9D0")],
            accentColor: Color(hex: "FFC107")
        ),
        OnboardingSlide(
            title: "Parent Dashboard",
            description: "Monitor progress reports, set daily screen time goals, and manage app access with secure passcode lock.",
            imageName: nil,
            systemImageName: "chart.bar.doc.horizontal.fill",
            gradientColors: [Color(hex: "F4F5FB"), Color(hex: "E6E8F7")],
            accentColor: Color(hex: "5C6BC0")
        )
    ]
    
    var body: some View {
        ZStack {
            // Animated background gradient based on selected slide
            LinearGradient(
                colors: slides[selectedTab].gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.6), value: selectedTab)
            
            // Decorative background blobs
            GeometryReader { geo in
                ZStack {
                    Circle()
                        .fill(slides[selectedTab].accentColor.opacity(0.12))
                        .frame(width: geo.size.width * 0.8)
                        .blur(radius: 60)
                        .offset(x: geo.size.width * 0.4, y: -geo.size.height * 0.1)
                    
                    Circle()
                        .fill(slides[selectedTab].accentColor.opacity(0.08))
                        .frame(width: geo.size.width * 0.9)
                        .blur(radius: 80)
                        .offset(x: -geo.size.width * 0.3, y: geo.size.height * 0.6)
                }
                .animation(.easeInOut(duration: 0.8), value: selectedTab)
            }
            
            VStack {
                // Top Navigation: Skip Button
                HStack {
                    Spacer()
                    if selectedTab < slides.count - 1 {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                onFinish()
                            }
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(slides[selectedTab].accentColor)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.6))
                                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                                )
                        }
                        .transition(.opacity)
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
                
                // TabView Carousel containing slides
                TabView(selection: $selectedTab) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        slideView(for: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Spacer()
                
                // Bottom Section: Navigation & Page Control
                VStack(spacing: 25) {
                    // Custom interactive indicator dots
                    HStack(spacing: 8) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    selectedTab = index
                                }
                            }) {
                                Circle()
                                    .fill(selectedTab == index ? slides[selectedTab].accentColor : Color.gray.opacity(0.3))
                                    .frame(width: selectedTab == index ? 24 : 8, height: 8)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedTab)
                            }
                        }
                    }
                    
                    // Main action button (Next / Get Started)
                    Button(action: handleNextButtonTap) {
                        HStack {
                            Text(selectedTab == slides.count - 1 ? "Get Started" : "Next")
                                .font(.system(size: 18, weight: .bold))
                            Image(systemName: selectedTab == slides.count - 1 ? "checkmark.circle.fill" : "arrow.right")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(slides[selectedTab].accentColor)
                                .shadow(color: slides[selectedTab].accentColor.opacity(0.4), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal, 32)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                }
                .padding(.bottom, 25)
            }
        }
        .onAppear {
            animateIllustration = true
        }
    }
    
    // View builder for each slide layout
    @ViewBuilder
    private func slideView(for index: Int) -> some View {
        let slide = slides[index]
        
        VStack(spacing: 30) {
            Spacer()
            
            // Image / Icon Visual representation
            ZStack {
                // Background outer glow ring
                Circle()
                    .stroke(slide.accentColor.opacity(0.1), lineWidth: 2)
                    .frame(width: 280, height: 280)
                    .scaleEffect(animateIllustration ? 1.05 : 0.95)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateIllustration)
                
                // Soft background circle
                Circle()
                    .fill(slide.accentColor.opacity(0.05))
                    .frame(width: 250, height: 250)
                
                if let assetName = slide.imageName, let image = UIImage(named: assetName) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                } else {
                    // Modern SFSymbol styled vector visual
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [slide.accentColor.opacity(0.2), slide.accentColor.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 180, height: 180)
                        
                        Image(systemName: slide.systemImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 85, height: 85)
                            .foregroundColor(slide.accentColor)
                            .shadow(color: slide.accentColor.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                }
            }
            .offset(y: animateIllustration ? -8 : 8)
            .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: animateIllustration)
            // Tap gesture on the card content itself to advance
            .onTapGesture {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                    if selectedTab < slides.count - 1 {
                        selectedTab += 1
                    }
                }
            }
            
            // Text Details Card
            VStack(spacing: 16) {
                Text(slide.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "2D2D2D"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                Text(slide.description)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "666666"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            .padding(.top, 10)
            // Tap gesture on the text card to advance
            .onTapGesture {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                    if selectedTab < slides.count - 1 {
                        selectedTab += 1
                    }
                }
            }
            
            Spacer()
        }
    }
    
    private func handleNextButtonTap() {
        if selectedTab < slides.count - 1 {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                selectedTab += 1
            }
        } else {
            onFinish()
        }
    }
}

// Button style to provide a premium scaling micro-interaction on tap
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    OnboardingCarouselView(onFinish: {})
}
