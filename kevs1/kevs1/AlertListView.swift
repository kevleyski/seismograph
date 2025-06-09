import SwiftUI

/// View that displays a list of alert groups
struct AlertListView: View {
    /// Alert history model containing consolidated alerts
    @ObservedObject var alertHistory: AlertHistory
    
    /// Custom colors for the app
    private let colors = Color.self
    
    /// Font sizes for dynamic type support
    private let bodyFont = DynamicFont(size: 17)
    private let captionFont = DynamicFont(size: 15)
    
    /// Spacing constants for consistent layout
    private let padding: CGFloat = 12
    
    /// Accessibility labels
    private let noAlertsLabel = "No alerts recorded yet"
    private let alertListLabel = "List of recent alert groups"
    
    var body: some View {
        List {
            if alertHistory.consolidatedAlerts.isEmpty {
                Text("No alerts yet")
                    .font(.system(size: captionFont.scaledSize))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityLabel(noAlertsLabel)
            } else {
                ForEach(alertHistory.consolidatedAlerts) { alert in
                    AlertRowView(alert: alert)
                }
            }
        }
        .listStyle(.plain)
        .accessibilityLabel(alertListLabel)
    }
}

/// View that displays a single consolidated alert row
struct AlertRowView: View {
    /// Consolidated alert to display
    let alert: ConsolidatedAlert
    
    /// Custom colors for the app
    private let colors = Color.self
    
    /// Font sizes for dynamic type support
    private let bodyFont = DynamicFont(size: 17)
    private let captionFont = DynamicFont(size: 15)
    
    /// Spacing constants for consistent layout
    private let padding: CGFloat = 8
    
    /// Accessibility labels
    private let timeLabel = "Alert time"
    private let durationLabel = "Alert duration"
    private let peakLabel = "Peak acceleration"
    private let thresholdLabel = "Threshold value"
    private let secondsLabel = "Duration in seconds"
    private let capturedValueLabel = "Captured value"
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        formatter.timeZone = .current
        return formatter.string(from: alert.timestamp)
    }
    
    var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter.string(from: alert.timestamp)
    }
    
    var body: some View {
        HStack {
            // Strongest axis indicator with color coding
            Text(alert.strongestAxis)
                .font(.system(size: captionFont.scaledSize))
                .frame(width: 30)
                .foregroundColor(axisColor(for: alert.strongestAxis))
            
            // Main content
            VStack(alignment: .leading, spacing: 4) {
                // Time and duration
                HStack {
                    Text(formattedTime)
                        .font(.system(size: bodyFont.scaledSize))
                        .accessibilityLabel(timeLabel)
                        .accessibilityValue(formattedTime)
                    Spacer()
                    Text("\(Int(alert.duration))s")
                        .font(.system(size: captionFont.scaledSize))
                        .foregroundColor(.secondary)
                        .accessibilityLabel(durationLabel)
                        .accessibilityValue("\(Int(alert.duration)) seconds")
                }
                
                // Start time and strongest axis value
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(formattedStartTime)
                            .font(.system(size: captionFont.scaledSize))
                            .foregroundColor(.secondary)
                            .accessibilityLabel("Start time")
                            .accessibilityValue(formattedStartTime)
                        Spacer()
                        Text("Strongest: \(alert.strongestAxis)")
                            .font(.system(size: bodyFont.scaledSize))
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .accessibilityLabel("Strongest axis")
                            .accessibilityValue(alert.strongestAxis)
                    }
                    
                    // Value and threshold
                    HStack {
                        Text("Value: \(alert.strongestValue, specifier: "%.2f") g")
                            .font(.system(size: bodyFont.scaledSize))
                            .foregroundColor(alert.strongestValue > alert.threshold ? .red : .primary)
                            .accessibilityLabel("Captured value")
                            .accessibilityValue("\(alert.strongestValue, specifier: "%.2f") g")
                        Spacer()
                        Text("Threshold: \(alert.threshold, specifier: "%.2f") g")
                            .font(.system(size: captionFont.scaledSize))
                            .foregroundColor(.secondary)
                            .accessibilityLabel("Threshold value")
                            .accessibilityValue("\(alert.threshold, specifier: "%.2f") g")
                    }
                    
                    // Peak value and threshold
                    HStack {
                        Text("Peak: \(alert.strongestValue, specifier: "%.2f") g")
                            .font(.system(size: bodyFont.scaledSize))
                            .foregroundColor(alert.strongestValue > alert.threshold ? .red : .primary)
                            .accessibilityLabel("Peak value")
                            .accessibilityValue("\(alert.strongestValue, specifier: "%.2f") g")
                        Spacer()
                        Text("Threshold: \(alert.threshold, specifier: "%.2f") g")
                            .font(.system(size: captionFont.scaledSize))
                            .foregroundColor(.secondary)
                            .accessibilityLabel("Threshold value")
                            .accessibilityValue("\(alert.threshold, specifier: "%.2f") g")
                    }
                }
                
                // Remove duplicate threshold line since it's already shown above
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    private func axisColor(for axis: String) -> Color {
        switch axis {
        case "X-axis": return .red
        case "Y-axis": return .green
        case "Z-axis": return .blue
        default: return .primary
        }
    }
}
