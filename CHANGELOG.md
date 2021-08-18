# iOS SDK changelog

The latest version of this file can be found at the master branch.

## 2.5.3 (2021-08-18)

### Added

- SwiftUI support
- Category and quantity fields in `CartItem` are made mandatory

## 2.5.2 (2021-08-17)

### Fixed

- Removed `deviceID` from the `mcID` part when sending a push notifications

## 2.5.1 (2021-06-03)

### Fixed

- Reduced requests quantity to timestamps endpoint 

## 2.5.0 (2021-06-01)

### Added

- Ability to run SDK without swizzling

### Fixed

- Handling expired S3 urls for in-app message content
- Automatic logins after logging out

## 2.4.1 (2021-05-21)

### Fixed

- Opening deep links with link tracking off from in-app messages

## 2.4.0 (2021-05-20)

### Added

- Public function `openDeepLink` to `CordialAPI` for opening deep links from client apps through SDK

## 2.3.0 (2021-05-12)

### Added

- Link tracking for in-app message links
- Handling html hyperlinks in in-app messages

## 2.2.0 (2021-04-20)

### Added

- Capturing inputs values from in-app messages

### Changed

- Do not send in-app message dismiss events on action clicks and input capturing
- Requesting push notification token and anonymously logging in a contact by default
- In-app messages content fetched sequentially

## 2.1.1 (2021-04-14)

### Fixed

- Fixed resending failed upsert contact requests

## 2.1.0 (2021-04-07)

### Added

-  Capturing inputs values from in-app messages

## 2.0.0 (2021-03-30)

### Added

- Inbox messages
- Handling deep links with link tracking on
- In-app messages reliability
- Current mcID can be set from a client app

## 0.4.25 (2021-02-09)

### Added

- Silent push notifications are passed to SDK from client application instead of relying on swizzling

## 0.4.24 (2020-12-11)

### Added

- Added logs around displaying imanges in push notifications

## 0.4.23 (2020-10-29)

### Fixed

- Fixed accessing SDK cache (CoreData storage) from multiple threads

## 0.4.22 (2020-10-06)

### Fixed

- Fixed sending duplicate events

## 0.4.21 (2020-08-17)

### Removed (1 change)

- Removed old push notification payload support for in-apps

### Fixed

- Fixed in-app messages living past their expiration time
- Fixed opening universal links on iOS 13 with scenes disabled

### Added

- Added milliseconds to timestamps sent by SDK
