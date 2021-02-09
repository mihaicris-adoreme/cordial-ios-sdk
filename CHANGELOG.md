# iOS SDK changelog

The latest version of this file can be found at the master branch.

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
