# iOS SDK changelog

The latest version of this file can be found at the master branch.

## 4.4.4 (2024-03-15)

### Fixed

- A rare crash that occurred when sending a custom event with a null value

## 4.4.3 (2024-01-05)

### Added

- Allow using vanity domains for all URLs

### Fixed

- Creating contacts from another account when switching environments

### Removed

- Timestamp from cart item payload data

## 4.4.2 (2023-11-20)

### Added

- `CryptoKit` for endpoint security
- Delivery of push notifications accompanied by in-app messages to the notification center

### Fixed

- Issue of location data not being cleared after location sharing is turned off
- Display issues of in-app messages while fetching their content

### Removed

- The parsing of deep link objects as strings in the JSON payload
- Deferred location updates for iOS 13 and higher

## 4.4.1 (2023-10-20)

### Changed

- Passing context instead of getting it every time when clearing SDK storage
- Updated deprecated `UNAuthorizationOptions.alert` to `.banner` and `.list`

## 4.4.0 (2023-09-27)

### Added

- CocoaPods support in Xcode 15
- Sending cacheable HTTP requests robustness improvement
- In-app multiple screens support
- Silent pushes SDK configuration
- Ability to setup `URLSession` configuration

### Removed

- Non-existent push notification format support

## 4.3.0 (2023-07-13)

### Added

- Exposing device information to the app developer 
- Removing cached custom events requests on HTTP callbacks
- In-app message delay type to the show in-app message call

### Changed

- Updated deprecated CoreData encode calls

## 4.2.1 (2023-05-30)

### Added

- Logger to catch SDK logs 
- System device notifications `optin`/`optout` events
- `deviceId`, `notificationStatus`, and `pushToken` are sent in system events' properties

## 4.2.0 (2023-05-03)

### Added

- Push notifications categories support

### Fixed

- Displaying IAM within system controllers

## 4.1.6 (2023-04-10)

### Added

- Updating a channel's `subscribeStatus` from the SDK

### Fixed

- Displaying an inbox image preview preloader 

## 4.1.5 (2023-03-24)

### Added

- Provisional push notifications support

### Fixed

- Redirecting schema deep links to browser

## 4.1.4 (2023-02-23)

### Fixed

- Fetching inbox messages intermittent crash

### Changed

- Catalog demo app product images and cart item URLs

## 4.1.3 (2022-12-23)

### Added

- Cache to carousel push notifications

## 4.1.2 (2022-12-14)

### Fixed

- Invoking correct deep links callback in scenes-disabled apps

## 4.1.1 (2022-10-11)

### Fixed

- Calling `unsetContact` prior to `setContact` does not break the SDK

## 4.1.0 (2022-09-19)

### Added

- Ability to set `String`, `Numeric`, and `Date` attributes to null 

## 4.0.3 (2022-09-07)

### Added

- Ability to initialize the SDK outside of `didFinishLaunchingWithOptions`

### Fixed

- Sending `crdl_app_open` event on receiving a push notification

## 4.0.2 (2022-07-22)

### Fixed

- Accessibility of `CordialDeepLink` from Objective-C

## 4.0.1 (2022-07-14)

### Added

- Device identifier output bypassing logs settings
- Display logs error output no matter of selected level

### Fixed

- IAM height calculation

## 4.0.0 (2022-06-21)

### Added

- Skipping tracking vanity deep link URL
- Carousel like rich push notifications 

### Changed

- Delegate and publisher deep link URL to `CordialDeepLink` class

## 3.1.5 (2022-07-04)

### Fixed

- Upsert contact attributes caching

## 3.1.4 (2022-05-03)

### Added

- Deep link URL inside system event properties 

### Fixed

- SwiftUI app opens invalid push deep links in a web browser

## 3.1.3 (2022-04-07)

### Fixed

- Integer overflow during prepare events for cashing   

### Changed

- The reason of flushing events from public API 

## 3.1.2 (2022-01-28)

### Fixed

- Subsequent `setContact` calls don't clear message attribution data

## 3.1.1 (2022-01-12)

### Changed

- In-app message height dynamically set based on content

### Fixed

- In-app message displayed until dismissed

## 3.1.0 (2021-12-29)

### Changed

- CoreData is accessed from the same thread

## 3.0.5 (2021-12-22)

### Fixed

- Receiving JWT on iPadOS 15.2

## 3.0.4 (2021-12-07)

### Fixed

- Not showing IAM after silent push notification arrived 

## 3.0.3 (2021-12-01)

### Fixed

- Processing notification status updates on the main queue
- Removed `fatalError` calls to prevent possible app crashes by the SDK

## 3.0.2 (2021-11-29)

### Fixed

- Synchronization of receiving multiple in-app messages

## 3.0.1 (2021-10-20)

### Fixed

- Allow upserting a contact without having a primary key 

## 3.0.0 (2021-10-12)

### Added

- Swift Package Manager support
- Unified interface for setting events stream and message hub service urls
- Handle case where app developer wants to open a deep link in the web browser
- Prevent possible SDK crashes on deserializing `Order`, `Address` and `CartItem` objects

### Removed

- Deprecated `CartItem` initialization

### Changed

- Rename `CordialAppExtensions_Swift` to `CordialAppExtensions`

## 2.6.2 (2021-09-13)

### Added

- Refactoring get resource bundle logic

## 2.6.1 (2021-09-03)

### Fixed

- Allow client apps to set their own `UNUserNotificationCenter` delegates

## 2.6.0 (2021-08-18)

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
