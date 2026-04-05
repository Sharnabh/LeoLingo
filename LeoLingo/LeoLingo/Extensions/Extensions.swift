//
//  Extensions.swift
//  LeoLingo
//
//  Created by Sharnabh on 20/02/25.
//

import SwiftUI
import UIKit

extension Color {
    /// Initializes a Color from a hex string (e.g. "#FF6347" or "FF6347").
    init(hex: String) {
        // Remove non-alphanumeric characters (e.g. '#' characters)
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Extension to get the top view controller
extension UIApplication {
    func getTopViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            // Handle navigation controllers
            if let navigationController = topController as? UINavigationController {
                return navigationController.visibleViewController
            }
            
            // Handle tab bar controllers
            if let tabController = topController as? UITabBarController {
                if let selected = tabController.selectedViewController {
                    return selected
                }
            }
            
            return topController
        }
        return nil
    }
}
