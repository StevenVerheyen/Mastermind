# Mastermind

`Mastermind` is an iOS sample app that implements the classic Mastermind-style letter guessing game in both `SwiftUI` and `UIKit`.

The app includes:

- A `SwiftUI` game tab
- A `UIKit` game tab
- An `Info` tab that explains the architecture, theming, and accessibility choices
- Shared game logic wired through factories, view models, a presenter, and an interactor (VIPER-ish architecture)
- Automated unit, behavior, and snapshot tests

## Requirements

- A recent version of `Xcode`
- iOS Simulator support for `iOS 18.0` or higher
- An `iPhone 17` simulator if you want to run the snapshot tests

Swift Package dependencies are resolved automatically by Xcode when the project is opened or built.

## Run The Project

### In Xcode

1. Open `Mastermind.xcodeproj`.
2. Select the `Mastermind` scheme.
3. Choose an iPhone or iPad simulator, or a connected iOS device.
4. Press `Run`.

### From The Command Line

You can also build and run from the command line with Xcode tooling. A common way to verify the app builds is:

```sh
xcodebuild -project "Mastermind.xcodeproj" -scheme "Mastermind" -destination "platform=iOS Simulator,name=iPhone 17" build
```

If you prefer, you can swap `iPhone 17` for any available simulator that supports the app's deployment target.

## Run The Tests

### In Xcode

1. Open `Mastermind.xcodeproj`.
2. Select the `Mastermind` scheme.
3. Press `Command-U` or use `Product > Test`.

### From The Command Line

The test suite can be run with:

```sh
xcodebuild test -project "Mastermind.xcodeproj" -scheme "Mastermind" -destination "platform=iOS Simulator,name=iPhone 17"
```

This command was verified successfully for this project.

## Notes About Snapshot Tests

Some tests use `SnapshotTesting` and `AccessibilitySnapshot`.

Those snapshot tests explicitly require the simulator name to be `iPhone 17`, so running tests on a different simulator may cause snapshot assertions to fail even if the app code is correct.

## Test Coverage Overview

The test target covers:

- Core game engine behavior
- Presenter and interactor logic
- SwiftUI and UIKit module behavior
- Accessibility-focused behavior
- Snapshot coverage for both UI implementations
