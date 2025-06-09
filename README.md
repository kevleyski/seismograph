# iOS Seismometer App

xcodebuild -project kevs1.xcodeproj -scheme kevs1 -configuration Debug -sdk iphonesimulator build

 
A simple seismometer app that uses the device's accelerometer to detect and record seismic activity.

## Features

- Real-time monitoring of X, Y, and Z axis acceleration
- Visual alerts when thresholds are exceeded
- History of detected events (last 8 events)
- Adjustable sensitivity threshold
- Simple and intuitive interface

## Apple Store Requirements

### Privacy
- Uses motion sensors only for detecting seismic activity
- No camera, microphone, or location data collection
- No personal data collection or sharing

### Performance
- Efficient motion sensor usage
- Minimal battery impact
- Smooth UI updates

### Accessibility
- VoiceOver support
- Dynamic type support
- Color contrast compliance
- Clear text labels and descriptions

### Security
- No network access required
- No data collection
- No third-party services

## Technical Details

- Built with SwiftUI
- Uses CoreMotion framework
- Supports iOS 15+
- Optimized for iPhone and iPad
- Dark mode support
- Dynamic type support
- Accessibility support

## Requirements

- iOS 15.0+
- Xcode 13.0+

## Usage

1. Open the app
2. Tap "Start Monitoring" to begin
3. Adjust the threshold slider to set your desired sensitivity
4. Watch for alerts when any axis exceeds the threshold
5. Tap "Stop Monitoring" to end monitoring

## Note

The app uses the device's built-in accelerometer to measure motion. The readings are in units of g-force (g), where 1g is the force of gravity at Earth's surface.



Notes

I've created a complete iOS seismometer app with these features:

Real-time monitoring of X, Y, and Z axis acceleration using CoreMotion
Visual display of acceleration values in g-force units
Adjustable threshold settings (0.1g to 2.0g)
Visual alerts (red background) when thresholds are exceeded
Start/Stop monitoring functionality
Modern SwiftUI interface with a clean, intuitive design
The app uses:

CMMotionManager for accelerometer data
ObservableObject for state management
SwiftUI for the UI
CoreMotion framework for motion data
To use the app:

Open it in Xcode
Run it on an iOS device or simulator
Start monitoring to see real-time acceleration data
Adjust the threshold slider to set your desired sensitivity
Watch for red alerts when any axis exceeds the threshold
The app will show the current acceleration values for each axis and highlight them in red when they exceed the set threshold. You can adjust the sensitivity by moving the threshold slider.

