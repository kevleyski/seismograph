import SwiftUI

/// View that displays alert history with graphs and recent alerts
struct AlertHistoryView: View {
    /// Seismometer model that handles accelerometer data and alert tracking
    @ObservedObject var seismometer: Seismometer
    
    /// Height of the alert list container
    @State private var alertListHeight: CGFloat = 200
    
    /// Custom colors for the app
    private let colors = Color.self
    
    /// Font sizes for dynamic type support
    private let titleFont = DynamicFont(size: 20)
    private let subtitleFont = DynamicFont(size: 17)
    private let bodyFont = DynamicFont(size: 15)
    
    /// Spacing constants for consistent layout
    private let spacing: CGFloat = 15
    private let sectionSpacing: CGFloat = 10
    private let padding: CGFloat = 12
    
    /// Accessibility labels
    private let graphsLabel = "Seismometer readings over time"
    private let alertsLabel = "Recent alert history"
    private let xLabel = "X-axis readings"
    private let yLabel = "Y-axis readings"
    private let zLabel = "Z-axis readings"
    
    var body: some View {
        ScrollView {
            VStack(spacing: spacing) {
                // Section title
                Text("Alert History")
                    .font(.system(size: titleFont.scaledSize))
                    .fontWeight(.bold)
                    .padding(.top, padding)
                    .accessibilityLabel("Alert history section")
                
                // Alert history graphs section
                VStack(spacing: sectionSpacing) {
                    Text("Alert History (Last 6 hours)")
                        .font(.system(size: subtitleFont.scaledSize))
                        .fontWeight(.bold)
                        .accessibilityLabel(graphsLabel)
                    
                    // Horizontal scrolling seismograph container
                    ScrollView(.horizontal) {
                        HStack(spacing: sectionSpacing) {
                            // X-axis seismograph
                            SeismographView(
                                events: seismometer.alertHistory.events.filter { $0.axis == "X" },
                                axis: "X-axis"
                            )
                            .frame(width: 200, height: 100)
                            .accessibilityLabel(xLabel)
                            
                            // Y-axis seismograph
                            SeismographView(
                                events: seismometer.alertHistory.events.filter { $0.axis == "Y" },
                                axis: "Y-axis"
                            )
                            .frame(width: 200, height: 100)
                            .accessibilityLabel(yLabel)
                            
                            // Z-axis seismograph
                            SeismographView(
                                events: seismometer.alertHistory.events.filter { $0.axis == "Z" },
                                axis: "Z-axis"
                            )
                            .frame(width: 200, height: 100)
                            .accessibilityLabel(zLabel)
                        }
                        .padding(.horizontal, padding)
                    }
                }
                
                // Alerts list
                AlertListView(alertHistory: seismometer.alertHistory)
                    .padding(.horizontal, padding)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}

#Preview {
    AlertHistoryView(seismometer: Seismometer())
}
