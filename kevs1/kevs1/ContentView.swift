//
//  ContentView.swift
//  kevs1
//
//  Created by Kev on 9/6/2025.
//

import SwiftUI
import CoreMotion

/// Main application view that displays seismometer readings and controls
struct ContentView: View {
    /// Seismometer model that handles accelerometer data and alert tracking
    @StateObject private var seismometer = Seismometer()
    
    /// Custom colors for the app
    private let colors = Color.self
    
    /// Spacing constants for consistent layout
    private let spacing: CGFloat = 20
    private let sectionSpacing: CGFloat = 15
    private let padding: CGFloat = 16
    
    /// Font sizes for dynamic type support
    private let titleFont = DynamicFont(size: 24)
    private let subtitleFont = DynamicFont(size: 20)
    private let bodyFont = DynamicFont(size: 17)
    
    /// Accessibility labels
    private let xLabel = "X-axis acceleration reading"
    private let yLabel = "Y-axis acceleration reading"
    private let zLabel = "Z-axis acceleration reading"
    private let thresholdLabel = "Acceleration threshold"
    private let monitoringLabel = "Start or stop seismometer monitoring"
    
    private func axisColor(for axis: String) -> Color {
        switch axis {
        case "X-axis": return colors.xAxis
        case "Y-axis": return colors.yAxis
        case "Z-axis": return colors.zAxis
        default: return .primary
        }
    }
    
    var body: some View {
        TabView {
            // Dashboard tab
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Seismometer")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        // Current readings section displays real-time acceleration data
                        VStack(spacing: sectionSpacing) {
                            Text("Current Readings")
                                .font(.system(size: subtitleFont.size))
                                .fontWeight(.bold)
                                .accessibilityLabel("Current acceleration readings")
                            
                            // X-axis display with visual alert indicator
                            VStack {
                                Text("X-axis")
                                    .font(.system(size: bodyFont.size))
                                    .accessibilityLabel(xLabel)
                                Text("Acceleration: \(seismometer.xAcceleration, specifier: "%.2f") g")
                                    .font(.system(size: titleFont.size))
                                    .accessibilityValue("\(seismometer.xAcceleration, specifier: "%.2f") g")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(padding)
                            .background(seismometer.isXAlert ? colors.alertBackground : colors.normalBackground)
                            .cornerRadius(10)
                            .accessibilityElement(children: .combine)
                            
                            // Y-axis display with visual alert indicator
                            VStack {
                                Text("Y-axis")
                                    .font(.system(size: bodyFont.size))
                                    .accessibilityLabel(yLabel)
                                Text("Acceleration: \(seismometer.yAcceleration, specifier: "%.2f") g")
                                    .font(.system(size: titleFont.size))
                                    .accessibilityValue("\(seismometer.yAcceleration, specifier: "%.2f") g")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(padding)
                            .background(seismometer.isYAlert ? colors.alertBackground : colors.normalBackground)
                            .cornerRadius(10)
                            .accessibilityElement(children: .combine)
                            
                            // Z-axis display with visual alert indicator
                            VStack {
                                Text("Z-axis")
                                    .font(.system(size: bodyFont.size))
                                    .accessibilityLabel(zLabel)
                                Text("Acceleration: \(seismometer.zAcceleration, specifier: "%.2f") g")
                                    .font(.system(size: titleFont.size))
                                    .accessibilityValue("\(seismometer.zAcceleration, specifier: "%.2f") g")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(padding)
                            .background(seismometer.isZAlert ? colors.alertBackground : colors.normalBackground)
                            .cornerRadius(10)
                            .accessibilityElement(children: .combine)
                        }
                        .padding(.horizontal)
                        
                        // Settings section with threshold control
                        VStack(spacing: sectionSpacing) {
                            Text("Settings")
                                .font(.system(size: bodyFont.size))
                                .accessibilityLabel("Acceleration threshold settings")
                            
                            // Threshold slider with value display
                            HStack {
                                Text("Threshold:")
                                    .font(.system(size: bodyFont.size))
                                Slider(value: $seismometer.threshold, in: 0.1...2.0, step: 0.1)
                                    .tint(colors.threshold)
                                    .accessibilityLabel(thresholdLabel)
                                    .accessibilityValue("\(seismometer.threshold, specifier: "%.1f") g")
                                Text("\(seismometer.threshold, specifier: "%.1f") g")
                                    .font(.system(size: bodyFont.size))
                            }
                            .padding(.horizontal, padding)
                        }
                        .padding(padding)
                        .background(colors.normalBackground)
                        .cornerRadius(10)
                        .accessibilityElement(children: .combine)
                        

                        
                        // Recent alerts summary
                        VStack(spacing: 15) {
                            Text("Recent Alerts")
                                .font(.title2)
                                .fontWeight(.bold)
                                .accessibilityLabel("List of recent alerts showing time, peak value, and duration")
                            
                            // Show last 8 alerts with detailed info
                            ForEach(seismometer.alertHistory.consolidatedAlerts.prefix(8)) { alert in
                                HStack {
                                    Text(alert.strongestAxis)
                                        .font(.headline)
                                        .frame(width: 30)
                                        .foregroundColor(axisColor(for: alert.strongestAxis))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(alert.timestamp.formatted(date: .omitted, time: .standard))
                                            .font(.subheadline)
                                            .accessibilityLabel("Alert time")
                                            .accessibilityValue(alert.timestamp.formatted(date: .omitted, time: .standard))
                                        
                                        HStack {
                                            Text("Peak: \(alert.strongestValue, specifier: "%.2f") g")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(alert.strongestValue > alert.threshold ? .red : .primary)
                                                .accessibilityLabel("Peak value")
                                                .accessibilityValue("\(alert.strongestValue, specifier: "%.2f") g")
                                            
                                            Spacer()
                                            
                                            Text("\(Int(alert.duration))s")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .accessibilityLabel("Duration")
                                                .accessibilityValue("\(Int(alert.duration)) seconds")
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // View all button
                            NavigationLink(destination: AlertHistoryView(seismometer: seismometer)) {
                                Text("View All Alerts")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                    .padding()
                }
                .navigationTitle("Dashboard")
            }
            
            // Alert History tab
            NavigationView {
                AlertHistoryView(seismometer: seismometer)
            }
            .navigationTitle("Alert History")
        }
    }
}

#Preview {
    ContentView()
}
