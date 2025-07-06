# StepKit

A Swift library for accessing step count data from HealthKit and CoreMotion with intelligent hybrid data aggregation.

## Features

- **Hybrid Data Source**: Automatically selects the best data source between HealthKit and CoreMotion
- **Intelligent Fallback**: Uses HealthKit when CoreMotion data is unavailable or fails
- **Real-time Updates**: CoreMotion-powered real-time step count updates
- **Historical Data**: Comprehensive access to historical step data through HealthKit
- **Modern Swift**: Built with async/await, actors, and Swift 6 concurrency

## Requirements

- iOS 16.0+

## Installation

### Swift Package Manager

Add StepKit to your project using Xcode or by adding it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/sugijotaro/StepKit.git", from: "1.0.0")
]
```

## Usage

### Basic Setup

```swift
import StepKit

// Create service instance
let stepService = await StepService()

// Request permissions
try await stepService.requestPermissions()
```

### Fetching Step Data

```swift
// Get today's steps
let todaySteps = try await stepService.fetchTodaySteps()
print("Steps today: \(todaySteps.steps) from \(todaySteps.source)")

// Get steps for a specific date range
let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
let endDate = Date()
let weekSteps = try await stepService.fetchSteps(from: startDate, to: endDate)
print("Steps this week: \(weekSteps.steps)")

// Get steps for specific date
let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
let yesterdaySteps = try await stepService.fetchStepsForSpecificDate(yesterday)
```

### Real-time Step Updates

```swift
// Start real-time updates
stepService.startRealtimeStepUpdates { stepData in
    print("Current steps: \(stepData.steps)")
}

// Stop updates when done
stepService.stopRealtimeStepUpdates()
```

### Advanced Configuration

```swift
// Custom configuration
let config = StepService.Configuration(
    useHybridMode: true,
    coreMotionLookbackDays: 7
)

let stepService = await StepService(
    healthKitProvider: customHealthKitProvider,
    coreMotionProvider: customCoreMotionProvider,
    configuration: config
)
```

## Data Sources

### Hybrid Mode

StepKit intelligently combines data from multiple sources:

- **Recent Data (≤7 days)**: Uses hybrid approach comparing HealthKit and CoreMotion, selecting the higher value
- **Historical Data (>7 days)**: Uses HealthKit exclusively for historical accuracy
- **Fallback**: Automatically falls back to available provider when one fails

### Data Source Priority

1. **Hybrid** (Recent data): `max(HealthKit, CoreMotion)`
2. **HealthKit** (Historical data or CoreMotion unavailable)
3. **CoreMotion** (HealthKit unavailable)

## Error Handling

```swift
do {
    let steps = try await stepService.fetchTodaySteps()
} catch StepServiceError.noProviderAvailable {
    print("No step data providers available")
} catch StepServiceError.permissionDenied {
    print("Permission denied for step data access")
} catch StepServiceError.dataNotAvailable {
    print("Step data not available for requested period")
}
```

## Testing

StepKit includes comprehensive unit tests with mock providers for easy testing of your applications.

```bash
swift test
```

## Architecture

### Core Components

- **StepService**: Main service class providing unified step data access
- **HealthKitStepProvider**: HealthKit integration for comprehensive historical data
- **CoreMotionStepProvider**: CoreMotion integration for recent data and real-time updates
- **StepData**: Unified data model with source tracking

### Protocol-Based Design

All providers implement protocols (`HealthKitStepProviding`, `CoreMotionStepProviding`) for easy testing and customization.

## Privacy & Permissions

StepKit requires appropriate permissions:

- **HealthKit**: Step count read permission
- **CoreMotion**: Motion activity permission

Always request permissions before accessing step data:

```swift
try await stepService.requestPermissions()
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions, issues, or feature requests, please open an issue on GitHub.

---

**Note**: This library is designed for iOS application that need reliable step count data with intelligent source selection and fallback mechanisms.
