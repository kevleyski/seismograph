import Foundation
import CoreMotion

class Seismometer: ObservableObject {
    private let motionManager = CMMotionManager()
    
    @Published var xAcceleration: Double = 0.0
    @Published var yAcceleration: Double = 0.0
    @Published var zAcceleration: Double = 0.0
    @Published var threshold: Double = 1.0
    @Published var isXAlert = false
    @Published var isYAlert = false
    @Published var isZAlert = false
    @Published var alertHistory = AlertHistory()
    
    var canStartMonitoring: Bool {
        motionManager.isAccelerometerAvailable
    }
    
    init() {
        setupMotionManager()
    }
    
    private func setupMotionManager() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1 // 10Hz
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
                guard let data = data else { return }
                
                DispatchQueue.main.async {
                    self?.xAcceleration = data.acceleration.x
                    self?.yAcceleration = data.acceleration.y
                    self?.zAcceleration = data.acceleration.z
                    
                    self?.checkAlerts()
                }
            }
        }
    }
    
    private func checkAlerts() {
        let axes = [("X", xAcceleration), ("Y", yAcceleration), ("Z", zAcceleration)]
        
        for (axis, acceleration) in axes {
            if abs(acceleration) > threshold {
                alertHistory.addEvent(axis: axis, acceleration: acceleration, threshold: threshold)
                
                // Reset alert states after recording
                switch axis {
                case "X": isXAlert = false
                case "Y": isYAlert = false
                case "Z": isZAlert = false
                default: break
                }
            }
        }
    }
    
    deinit {
        motionManager.stopAccelerometerUpdates()
    }
}
