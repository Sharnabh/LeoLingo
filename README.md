# LeoLingo 🦁🎓

LeoLingo is an innovative iOS educational app designed to help children learn pronunciation and language skills through interactive games, vocal coaching, and fun activities. Built with Swift and UIKit/SwiftUI, the app combines speech recognition technology with gamification to create an engaging learning experience.

## 🌟 Features

### 🎯 Core Learning Modules

#### 1. **Vocal Coach** 🎤
- **Speech Recognition**: Advanced speech processing with accuracy measurement
- **Interactive Cards**: Swipeable word cards with visual feedback
- **Real-time Feedback**: Instant pronunciation scoring with visual accuracy meters
- **Progress Tracking**: Individual word practice history and improvement metrics
- **Noise Monitoring**: Environmental noise detection for optimal recording conditions

#### 2. **Fun Learning Games** 🎮
- **Jungle Run**: Interactive adventure game
- **Flash Cards**: Two implementations:
  - Original UIKit-based flashcards
  - Modern SwiftUI flashcards with 3D animations and confetti effects
- **Sing Along**: Poetry recitation with audio synchronization and scoring

#### 3. **Educational Content** 📚
- **Categorized Learning**: Words organized by themes (Animals, Occupations, Weather, etc.)
- **Fun Facts**: Educational trivia for each word to enhance learning
- **Multiple Difficulty Levels**: Progressive difficulty system
- **Badge System**: Achievement tracking with various animal-themed badges

### 🔧 Technical Features

#### Authentication & User Management
- **Multiple Sign-in Options**: 
  - Email/Password with OTP verification
  - Google Sign-In integration
  - Apple Sign-In support
- **User Profiles**: Personalized learning paths and progress tracking
- **Parent Mode**: Separate interface for parent oversight

#### Audio & Speech Processing
- **Speech Recognition**: Real-time speech-to-text with accuracy calculation
- **Text-to-Speech**: Natural voice synthesis for word pronunciation
- **Audio Recording**: High-quality voice recording capabilities
- **Background Music**: Immersive audio experience with sound effects

#### Data Management
- **Supabase Backend**: Cloud-based data storage and synchronization
- **Core Data**: Local data persistence
- **Real-time Sync**: Automatic progress synchronization across devices

## 🏗️ Architecture

### Project Structure
```
LeoLingo/
├── Controllers/
│   ├── VocalCoach/          # Speech recognition and practice
│   ├── FunLearning/         # Educational games
│   ├── ParentMode/          # Parent dashboard
│   └── Onboarding/          # User registration flow
├── Data Models/             # Core data structures
├── Managers/               # Service layer (Audio, Badges, etc.)
├── Views/                  # UI components and layouts
├── Extensions/             # Swift extensions and utilities
└── Services/               # External service integrations
```

### Key Components

#### Data Models
- **UserData**: User profiles with learning progress
- **Level**: Grouped word collections with difficulty progression
- **Word**: Individual learning units with pronunciation records
- **Badge**: Achievement system for motivation
- **Poem**: Structured content for sing-along activities

#### Managers
- **VoiceManager**: Text-to-speech functionality
- **BadgeEarningManager**: Achievement tracking and rewards
- **CoreDataManager**: Local data persistence
- **OTPService**: Email-based verification system

#### Speech Processing
- **SpeechProcessor**: Advanced speech recognition with Levenshtein distance calculation
- **GameSpeechProcessor**: Specialized processor for game interactions
- Real-time accuracy measurement and feedback

## 🚀 Getting Started

### Prerequisites
- Xcode 14.0+
- iOS 15.0+
- Swift 5.7+
- Active Apple Developer Account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Sharnabh/LeoLingo.git
   cd LeoLingo
   ```

2. **Configure External Services**

   #### Google Sign-In Setup
   - Create a project in [Google Developers Console](https://console.developers.google.com/)
   - Enable Google Sign-In API
   - Download `GoogleService-Info.plist` and add to Xcode project
   - Configure URL schemes in Info.plist

   #### Supabase Configuration
   - Set up Supabase project with user authentication
   - Configure database schema (see setup documentation)
   - Update connection strings in `SupabaseDataController`

   #### Email OTP Service
   - Configure SMTP settings in `OTPService.swift`
   - Set up email provider credentials

3. **Install Dependencies**
   - GoogleSignIn SDK (via Swift Package Manager)
   - Supabase Swift SDK
   - Other required frameworks (automatically managed)

4. **Build and Run**
   ```bash
   # Open in Xcode
   open LeoLingo.xcodeproj
   
   # Or use command line
   xcodebuild -project LeoLingo.xcodeproj -scheme LeoLingo build
   ```

## 🎮 How to Use

### For Children
1. **Sign Up**: Create account with parent's email
2. **Voice Setup**: Complete voice calibration
3. **Start Learning**: Choose from vocal coach or fun games
4. **Practice Words**: Speak into the microphone for pronunciation feedback
5. **Earn Badges**: Complete challenges to unlock achievements
6. **Play Games**: Enjoy educational mini-games

### For Parents
1. **Parent Mode**: Access child's progress dashboard
2. **Monitor Progress**: View learning analytics and achievements
3. **Set Goals**: Configure practice schedules and targets
4. **Review Reports**: Track improvement over time

## 🏆 Badge System

LeoLingo features an engaging achievement system with animal-themed badges:

- **🐝 Bee Badge**: First word completion
- **🐢 Turtle Badge**: Consistent practice
- **🐘 Elephant Badge**: Memory achievements
- **🐕 Dog Badge**: Loyalty and regular usage
- **🐰 Bunny Badge**: Speed improvements
- **🦁 Lion Badge**: Leadership in pronunciation

## 🔊 Speech Recognition Technology

### Features
- **Real-time Processing**: Instant speech-to-text conversion
- **Accuracy Measurement**: Levenshtein distance algorithm for pronunciation scoring
- **Noise Filtering**: Background noise detection and management
- **Multi-language Support**: Optimized for children's speech patterns

### Privacy & Security
- **Local Processing**: Speech data processed on-device when possible
- **Secure Storage**: Encrypted user data and recordings
- **COPPA Compliance**: Child privacy protection measures

## 🎨 UI/UX Design

### Design Principles
- **Child-Friendly**: Bright colors, large buttons, intuitive navigation
- **Accessibility**: VoiceOver support, adjustable text sizes
- **Responsive**: Adapts to different screen sizes and orientations
- **Engaging**: Animations, sound effects, and visual feedback

### Technologies Used
- **UIKit**: Primary UI framework
- **SwiftUI**: Modern components and animations
- **Core Animation**: Smooth transitions and effects
- **Lottie**: Advanced animations and micro-interactions

## 📊 Analytics & Progress Tracking

### Metrics Tracked
- **Pronunciation Accuracy**: Word-by-word scoring
- **Practice Frequency**: Daily/weekly usage patterns
- **Learning Velocity**: Speed of improvement
- **Game Performance**: Scores and completion rates

### Data Visualization
- Progress charts and graphs
- Achievement timelines
- Performance comparisons
- Learning path recommendations

## 🛠️ Development

### Requirements
- **Language**: Swift 5.7+
- **Frameworks**: UIKit, SwiftUI, AVFoundation, Speech, Core Data
- **Architecture**: MVC with MVVM for SwiftUI components
- **Testing**: XCTest framework for unit and UI testing

### Build Configuration
- **Debug**: Development builds with logging and debug features
- **Release**: Optimized production builds
- **Testing**: Dedicated configuration for automated testing

### Code Style
- Swift Style Guide compliance
- Comprehensive documentation
- Modular architecture for maintainability

## 📱 Supported Devices

- **iPhone**: iOS 15.0+
- **iPad**: iPadOS 15.0+
- **Processor**: A12 Bionic chip or newer recommended
- **Storage**: Minimum 1GB available space
- **Microphone**: Required for speech recognition features

## � Security & Legal

### Intellectual Property Protection
LeoLingo is protected by comprehensive intellectual property rights including:
- **Source Code**: Proprietary algorithms and implementations
- **Educational Content**: Original curricula and learning methodologies  
- **User Interface**: Custom designs and user experience elements
- **Trademarks**: LeoLingo™ brand and associated marks

### Anti-Piracy Technology
- Code obfuscation and runtime protection
- App Store receipt validation
- Tamper detection and prevention
- Usage analytics and monitoring

### Legal Compliance
- COPPA compliant for children's privacy
- GDPR ready for international users
- App Store guidelines adherent
- Enterprise security standards

**⚠️ Legal Warning**: Unauthorized copying, distribution, or reverse engineering of this software is strictly prohibited and may result in legal action.

## �📄 License

**LeoLingo is proprietary software protected by copyright and commercial license.**

This software is licensed under a commercial license agreement. Unauthorized copying, distribution, modification, or reverse engineering is strictly prohibited. The software is protected by copyright laws and international treaties.

For licensing inquiries or commercial use permissions, please contact: vopulse@icloud.com

See the [LICENSE](LICENSE) file for complete terms and conditions.

## 🆘 Support

For technical support or feature requests:
- **Email**: vopulse@icloud.com
- **Documentation**: Check setup guides in the repository
- **Issues**: Use GitHub issues for bug reports

## 🙏 Acknowledgments

- Speech recognition powered by Apple's Speech framework
- Audio processing using AVFoundation
- Backend services by Supabase
- Authentication services by Google and Apple
- Educational content reviewed by child development experts

---

**LeoLingo** - Making language learning fun and engaging for children! 🦁✨
