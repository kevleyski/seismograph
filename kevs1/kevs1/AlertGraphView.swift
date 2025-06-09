import SwiftUI

struct AlertGraphView: View {
    let events: [AlertEvent]
    let axis: String
    
    private let graphHeight: CGFloat = 200
    private let thresholdLineThickness: CGFloat = 2
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                // Background
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: graphHeight)
                
                // Threshold line
                Path { path in
                    let threshold = events.first?.threshold ?? 1.0
                    let y = graphHeight * (1 - threshold)
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
                .stroke(Color.red, lineWidth: thresholdLineThickness)
                
                // Graph line
                if !events.isEmpty {
                    Path { path in
                        let firstPoint = CGPoint(
                            x: 0,
                            y: graphHeight * (1 - events[0].acceleration)
                        )
                        path.move(to: firstPoint)
                        
                        for (index, event) in events.enumerated() {
                            let x = CGFloat(index) * (geometry.size.width / CGFloat(events.count))
                            let y = graphHeight * (1 - event.acceleration)
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    .stroke(Color.blue, lineWidth: 2)
                }
                
                // Timestamp labels
                VStack(alignment: .leading) {
                    Text(events.first?.timestamp.formatted(date: .omitted, time: .shortened) ?? "")
                        .font(.caption)
                    Spacer()
                    Text(events.last?.timestamp.formatted(date: .omitted, time: .shortened) ?? "")
                        .font(.caption)
                }
                .padding(.horizontal)
            }
            .frame(height: graphHeight)
            .overlay(
                Text(axis)
                    .font(.headline)
                    .padding(.leading),
                alignment: .topLeading
            )
        }
    }
}
