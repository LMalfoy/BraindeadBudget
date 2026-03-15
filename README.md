# PocketBudget

PocketBudget is a small SwiftUI budgeting app MVP for iPhone. It lets you:

- set a monthly budget
- add expenses
- see what is left for the current month
- browse saved expenses

## Requirements

- macOS with Xcode 15 or newer
- iOS 17 simulator or device

## Run the app

1. Open `PocketBudget.xcodeproj` in Xcode.
2. Choose an iPhone simulator like `iPhone 16`.
3. Press `Run`.

If you want to run on a physical device, set your own signing team in the `PocketBudget` target under `Signing & Capabilities`.

## Run tests

1. Open `PocketBudget.xcodeproj`.
2. Press `Cmd+U` to run the unit tests and UI tests.

## Notes

- Data is stored locally with SwiftData.
- Remaining budget is calculated from expenses in the current calendar month.
- This scaffold was created in a Linux workspace, so the Swift/Xcode build was not executed here. Opening the project in Xcode is the intended validation step.
