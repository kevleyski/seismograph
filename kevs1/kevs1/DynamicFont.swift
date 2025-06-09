import SwiftUI

/// Font that supports dynamic type scaling
struct DynamicFont {
    /// Base font size
    let size: CGFloat
    
    /// Create a dynamic font with a base size
    init(size: CGFloat) {
        self.size = size
    }
    
    /// Get a scaled font size based on the current content size category
    var scaledSize: CGFloat {
        let maxSize = size * 2.5 // Maximum scale factor of 2.5x
        let minSize = size * 0.5 // Minimum scale factor of 0.5x
        
        let sizeCategory = UIScreen.main.traitCollection.preferredContentSizeCategory
        let scaleFactor: CGFloat
        
        switch sizeCategory {
        case .accessibilityExtraExtraLarge:
            scaleFactor = 2.5
        case .accessibilityExtraLarge:
            scaleFactor = 2.0
        case .accessibilityLarge:
            scaleFactor = 1.75
        case .extraExtraLarge:
            scaleFactor = 1.5
        case .extraLarge:
            scaleFactor = 1.3
        case .large:
            scaleFactor = 1.1
        default:
            scaleFactor = 1.0
        }
        
        return min(max(size * scaleFactor, minSize), maxSize)
    }
}
