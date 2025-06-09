import Foundation

/// Represents a consolidated alert with the strongest axis and its value
struct ConsolidatedAlert: Identifiable {
    let id = UUID()
    let timestamp: Date
    let strongestAxis: String
    let strongestValue: Double
    let threshold: Double
    let duration: TimeInterval
    
    var formattedDuration: String {
        let seconds = Int(duration)
        if seconds < 60 {
            return "\(seconds)s"
        } else {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return "\(minutes)m \(remainingSeconds)s"
        }
    }
}

struct AlertEvent: Identifiable, Equatable {
    let id = UUID()
    let timestamp: Date
    let axis: String
    let acceleration: Double
    let threshold: Double

    static func == (lhs: AlertEvent, rhs: AlertEvent) -> Bool {
        lhs.id == rhs.id
    }
}

struct AlertGroup: Identifiable {
    let id: String
    let axis: String
    let startTime: Date
    let endTime: Date
    let peakValue: Double
    let peakTime: Date
    let threshold: Double
    
    init(id: String = UUID().uuidString, axis: String, startTime: Date, endTime: Date, peakValue: Double, peakTime: Date, threshold: Double) {
        self.id = "\(axis)_\(startTime.timeIntervalSince1970)"
        self.axis = axis
        self.startTime = startTime
        self.endTime = endTime
        self.peakValue = peakValue
        self.peakTime = peakTime
        self.threshold = threshold
    }
    
    var duration: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
    
    var formattedDuration: String {
        let seconds = Int(duration)
        if seconds < 60 {
            return "\(seconds)s"
        } else {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return "\(minutes)m \(remainingSeconds)s"
        }
    }
}

class AlertHistory: ObservableObject {
    @Published var events: [AlertEvent] = []
    @Published var alertGroups: [AlertGroup] = []
    @Published var consolidatedAlerts: [ConsolidatedAlert] = []
    @Published var lastResetTime: Date
    
    private var currentGroups: [String: AlertGroup] = [:]
    
    init() {
        // Initialize with current time
        lastResetTime = Date()
        setupResetTimer()
    }
    
    func addEvent(axis: String, acceleration: Double, threshold: Double) {
        let event = AlertEvent(
            timestamp: Date(),
            axis: axis,
            acceleration: acceleration,
            threshold: threshold
        )
        
        events.append(event)
        updateAlertGroup(for: axis, acceleration: acceleration, threshold: threshold)
    }
    
    private func updateAlertGroup(for axis: String, acceleration: Double, threshold: Double) {
        if let existingGroup = currentGroups[axis] {
            // Update existing group
            let newGroup = AlertGroup(
                id: existingGroup.id,
                axis: axis,
                startTime: existingGroup.startTime,
                endTime: Date(),
                peakValue: max(existingGroup.peakValue, abs(acceleration)),
                peakTime: abs(acceleration) > existingGroup.peakValue ? Date() : existingGroup.peakTime,
                threshold: threshold
            )
            
            // Update consolidated alerts
            updateConsolidatedAlerts()
            currentGroups[axis] = newGroup
            currentGroups[axis] = newGroup
        } else {
            // Create new group
            let newGroup = AlertGroup(
                id: "\(axis)_\(Date().timeIntervalSince1970)",
                axis: axis,
                startTime: Date(),
                endTime: Date(),
                peakValue: abs(acceleration),
                peakTime: Date(),
                threshold: threshold
            )
            currentGroups[axis] = newGroup
        }
    }
    
    func endAlertGroup(for axis: String) {
        if let group = currentGroups.removeValue(forKey: axis) {
            alertGroups.append(group)
        }
    }
    
    private func setupResetTimer() {
        // Reset every 6 hours
        let resetInterval = 6 * 60 * 60 // 6 hours in seconds
        
        // Calculate next reset time
        let calendar = Calendar.current
        let nextReset = calendar.date(byAdding: .hour, value: 6, to: lastResetTime)!
        
        // Schedule timer
        Timer.scheduledTimer(withTimeInterval: nextReset.timeIntervalSinceNow, repeats: false) { [weak self] _ in
            self?.resetHistory()
        }
    }
    
    private func resetHistory() {
        events.removeAll()
        alertGroups.removeAll()
        currentGroups.removeAll()
        lastResetTime = Date()
        setupResetTimer() // Schedule next reset
    }
    
    func getEventsForAxis(_ axis: String) -> [AlertEvent] {
        return events.filter { $0.axis == axis }
    }
    
    func getAlertGroupsForAxis(_ axis: String) -> [AlertGroup] {
        return alertGroups.filter { $0.axis == axis }
    }
    
    func getRecentAlertGroups(limit: Int = 10) -> [AlertGroup] {
        return Array(alertGroups
            .sorted { $0.endTime > $1.endTime }
            .prefix(limit))
    }
    
    private func updateConsolidatedAlerts() {
        // Find the strongest alert among all axes
        if let strongestGroup = currentGroups.values.max(by: { $0.peakValue < $1.peakValue }) {
            let consolidatedAlert = ConsolidatedAlert(
                timestamp: strongestGroup.endTime,
                strongestAxis: strongestGroup.axis,
                strongestValue: strongestGroup.peakValue,
                threshold: strongestGroup.threshold,
                duration: strongestGroup.duration
            )
            
            // Add to consolidated alerts if it's not already present
            if !consolidatedAlerts.contains(where: { $0.timestamp == consolidatedAlert.timestamp }) {
                consolidatedAlerts.append(consolidatedAlert)
                consolidatedAlerts = consolidatedAlerts.sorted { $0.timestamp > $1.timestamp }
            }
        }
    }
}
