import SwiftUI

/// Custom colors for the seismometer app
extension Color {
    /// Color for X-axis (red)
    static let xAxis = Color.red
    
    /// Color for Y-axis (green)
    static let yAxis = Color.green
    
    /// Color for Z-axis (blue)
    static let zAxis = Color.blue
    
    /// Color for alert states
    static let alertBackground = Color.red.opacity(0.1)
    
    /// Color for normal states
    static let normalBackground = Color.secondary.opacity(0.1)
    
    /// Color for threshold
    static let threshold = Color.red
    
    /// Color for grid lines
    static let grid = Color.secondary.opacity(0.3)
}
