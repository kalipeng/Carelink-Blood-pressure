//
//  UIScreen+DeviceSize.swift
//  carelink
//
//  Screen size detection helper for responsive design
//

import UIKit

extension UIScreen {
    
    // MARK: - Screen Size Categories
    
    /// Detect if current device is a small screen (iPhone SE, iPhone 13 mini, etc.)
    static var isSmallScreen: Bool {
        return main.bounds.height < 700 // iPhone SE: 667, mini: 812
    }
    
    /// Detect if current device is a compact screen (standard iPhone)
    static var isCompactScreen: Bool {
        return main.bounds.height < 850 // Most standard iPhones
    }
    
    /// Detect if current device is a large screen (Pro Max, Plus models)
    static var isLargeScreen: Bool {
        return main.bounds.height > 900 // iPhone Pro Max, etc.
    }
    
    // MARK: - Responsive Values
    
    /// Get adaptive font size based on screen size
    /// - Parameters:
    ///   - small: Font size for small screens (iPhone SE)
    ///   - regular: Font size for regular screens (iPhone 15)
    ///   - large: Font size for large screens (iPhone Pro Max)
    /// - Returns: Appropriate font size for current device
    static func adaptiveFont(small: CGFloat, regular: CGFloat, large: CGFloat) -> CGFloat {
        if isSmallScreen {
            return small
        } else if isLargeScreen {
            return large
        } else {
            return regular
        }
    }
    
    /// Get adaptive spacing based on screen size
    /// - Parameters:
    ///   - small: Spacing for small screens
    ///   - regular: Spacing for regular screens
    ///   - large: Spacing for large screens
    /// - Returns: Appropriate spacing for current device
    static func adaptiveSpacing(small: CGFloat, regular: CGFloat, large: CGFloat) -> CGFloat {
        if isSmallScreen {
            return small
        } else if isLargeScreen {
            return large
        } else {
            return regular
        }
    }
    
    /// Get adaptive padding based on screen size
    static var adaptivePadding: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 60 // iPad
        } else if isSmallScreen {
            return 16 // iPhone SE
        } else {
            return 24 // Standard iPhone
        }
    }
    
    /// Get adaptive vertical spacing
    static var adaptiveVerticalSpacing: CGFloat {
        if isSmallScreen {
            return 12 // Compact spacing for small screens
        } else if isCompactScreen {
            return 20 // Standard spacing
        } else {
            return 30 // Generous spacing for large screens
        }
    }
    
    /// Get adaptive button height
    static var adaptiveButtonHeight: CGFloat {
        return adaptiveSpacing(small: 44, regular: 50, large: 56)
    }
}
