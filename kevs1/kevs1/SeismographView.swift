import SwiftUI
import CoreMotion

/// Custom view for drawing a grid background
struct CustomGrid: View {
    let width: CGFloat
    let height: CGFloat
    let tickSpacing: CGFloat
    let tickLength: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Vertical grid lines
                ForEach(0..<Int(width/tickSpacing), id: \.self) { i in
                    let x = CGFloat(i) * tickSpacing
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: tickSpacing, height: height)
                        .offset(x: x)
                }
                
                // Horizontal grid lines
                ForEach(0..<Int(height/tickSpacing), id: \.self) { i in
                    let y = CGFloat(i) * tickSpacing
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: width, height: tickSpacing)
                        .offset(y: y)
                }
                
                // Edge lines
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: tickLength, height: height)
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: width, height: tickLength)
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: tickLength, height: height)
                    .offset(x: width - tickLength)
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: width, height: tickLength)
                    .offset(y: height - tickLength)
            }
        }
    }
}

/// View that displays seismograph-style vertical scrolling graph
struct SeismographView: View {
    /// Accelerometer events to display
    let events: [AlertEvent]
    
    /// Axis being displayed (X, Y, or Z)
    let axis: String
    
    /// Graph dimensions and styling
    let graphWidth: CGFloat = 300
    let graphHeight: CGFloat = 200
    let lineThickness: CGFloat = 2
    let tickSpacing: CGFloat = 20
    let tickLength: CGFloat = 10
    
    /// Constants for performance optimization
    private let maxEventsToShow = 200
    private let middleLineThickness: CGFloat = 1
    
    /// Font sizes for dynamic type support
    private let bodyFont = DynamicFont(size: 17)
    
    /// Get color for a given axis
    private func axisColor(for axis: String) -> Color {
        switch axis {
        case "X-axis": return .red
        case "Y-axis": return .green
        case "Z-axis": return .blue
        default: return .primary
        }
    }
    
    /// Spacing constants for consistent layout
    private let padding: CGFloat = 10
    
    /// Scale factor for acceleration values
    private let scaleFactor: CGFloat
    
    /// Accessibility labels
    private let timestampLabel = "Graph timestamps"
    private var graphLabel: String
    
    init(events: [AlertEvent], axis: String) {
        self.events = events
        self.axis = axis
        
        // Calculate scale factor in init to avoid SwiftUI rendering issues
        let filteredEvents = Array(events.suffix(maxEventsToShow))
        let maxValue = filteredEvents.map { abs($0.acceleration) }.max() ?? 1.0
        self.scaleFactor = (graphHeight * 0.2) / maxValue
        
        // Initialize accessibility label after properties are set
        self.graphLabel = "Seismograph graph showing \(axis) axis readings"
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                // Background with grid
                CustomGrid(width: graphWidth, height: graphHeight, tickSpacing: tickSpacing, tickLength: tickLength)
                
                // Middle line
                Path { path in
                    path.move(to: CGPoint(x: 0, y: graphHeight / 2))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: graphHeight / 2))
                }
                .stroke(Color.gray.opacity(0.3), lineWidth: middleLineThickness)
                
                // Threshold line
                Path { path in
                    let threshold = events.first?.threshold ?? 1.0
                    let y = graphHeight * (1 - threshold)
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
                .stroke(Color.red, lineWidth: lineThickness)
                
                // Seismograph line
                if !events.isEmpty {
                    Path { path in
                        let filteredEvents = Array(events.suffix(maxEventsToShow))
                        var x = geometry.size.width
                        
                        for (index, event) in filteredEvents.enumerated() {
                            let y = graphHeight / 2 + (event.acceleration * scaleFactor)
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                            
                            x -= geometry.size.width / CGFloat(filteredEvents.count)
                        }
                    }
                    .stroke(axisColor(for: axis), lineWidth: lineThickness)
                    .accessibilityLabel(graphLabel)
                    .accessibilityHint("Shows \(axis) axis acceleration readings over time")
                }
                // Background with grid
                CustomGrid(width: graphWidth, height: graphHeight, tickSpacing: tickSpacing, tickLength: tickLength)

                
                // Middle line
                Path { path in
                    path.move(to: CGPoint(x: 0, y: graphHeight / 2))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: graphHeight / 2))
                }
                .stroke(Color.gray.opacity(0.3), lineWidth: middleLineThickness)
                
                // Threshold line
                Path { path in
                    let threshold = events.first?.threshold ?? 1.0
                    let y = graphHeight * (1 - threshold)
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
                .stroke(Color.red, lineWidth: lineThickness)
                
                // Seismograph line
                if !events.isEmpty {
                    Path { path in
                        let filteredEvents = Array(events.suffix(maxEventsToShow))
                        var x = geometry.size.width
                        
                        for (index, event) in filteredEvents.enumerated() {
                            let y = graphHeight / 2 + (event.acceleration * scaleFactor)
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                            
                            x -= geometry.size.width / CGFloat(filteredEvents.count)
                        }
                    }
                    .stroke(Color.blue, lineWidth: lineThickness)
                }
                
                // Alert dots
                if !events.isEmpty {
                    let filteredEvents = Array(events.suffix(maxEventsToShow))
                    ForEach(filteredEvents.indices, id: \.self) { index in
                        let event = filteredEvents[index]
                        if abs(event.acceleration) > event.threshold {
                            let positionX = geometry.size.width * (1 - CGFloat(index) / CGFloat(filteredEvents.count))
                            let positionY = graphHeight / 2 + (event.acceleration * scaleFactor)
                            
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .position(x: positionX, y: positionY)
                        }
                    }
                }
                
                // Timestamp labels
                VStack(alignment: .leading, spacing: 0) {
                    Text(events.first?.timestamp.formatted(date: .omitted, time: .shortened) ?? "")
                        .font(.system(size: bodyFont.scaledSize))
                        .accessibilityLabel("First timestamp")
                        .accessibilityValue(events.first?.timestamp.formatted(date: .omitted, time: .shortened) ?? "")
                    Spacer()
                    Text(events.last?.timestamp.formatted(date: .omitted, time: .shortened) ?? "")
                        .font(.system(size: bodyFont.scaledSize))
                        .accessibilityLabel("Last timestamp")
                        .accessibilityValue(events.last?.timestamp.formatted(date: .omitted, time: .shortened) ?? "")
                }
                .padding(.horizontal, padding)
            }
            .frame(width: geometry.size.width, height: graphHeight)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    SeismographView(events: [
        AlertEvent(timestamp: Date(), axis: "X", acceleration: 0.5, threshold: 1.0),
        AlertEvent(timestamp: Date().addingTimeInterval(1), axis: "X", acceleration: 0.8, threshold: 1.0),
        AlertEvent(timestamp: Date().addingTimeInterval(2), axis: "X", acceleration: -0.3, threshold: 1.0)
    ], axis: "X-axis")
}
