# SwiftUI Flashcard Game

This is a modern flashcard game built with SwiftUI that offers engaging, animated learning experiences for children.

## Features

- **Category Selection**: Visually appealing grid of categories with animations
- **Themed Backgrounds**: Each category has a unique background and color theme
- **Interactive Flashcards**: 
  - Flip cards with 3D animations
  - Swipe left/right to navigate between cards
  - Text-to-speech pronunciation when tapping cards
  - Fun confetti animations
- **Accessibility**: Voice feedback for words

## Integration with Existing App

The flashcard game is integrated with the existing LeoLingo app via the `FunLearningViewController.swift` file. When users tap on the Flashcard option, they're presented with a choice between:
- Original UIKit-based flashcards
- New SwiftUI-based flashcards

## Setup Instructions

1. **Images**: 
   - Add real images to the `Assets.xcassets/NewFlashCards` folder
   - Required image assets:
     - Category icons: `vegetables`, `wild_animals`, `weather`, etc.
     - Background images: `jungle_background`, `vegetables_bg`, `jungle_bg`, etc.
     - Card images for each word (e.g., `broccoli`, `carrot`, `elephant`)

2. **Customizing Categories and Words**:
   - Open `SwiftUIFlashCardData.swift` to modify, add or remove categories and words
   - Each category has:
     - Name
     - Image (icon)
     - Color theme
     - Background image
     - List of flashcards

## Architecture

- **SwiftUIFlashCardData.swift**: Data model and speech functionality
- **CategorySelectionView.swift**: Grid view of category options
- **FlashCardView.swift**: Interactive flashcard experience
- **SwiftUIFlashCardConnector.swift**: Bridge between UIKit and SwiftUI

## Design Notes

- The app features a nature-inspired theme with animated floating leaves
- Each category has a distinctive color scheme
- Animations prioritize smooth performance and child-friendly interactions
- Text-to-speech provides pronunciation help 