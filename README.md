# iOS Cordial SDK Documentation
## Contents

[Installation](#installation)<br>
[Initialize the SDK](#initialize-the-sdk)<br>
[Setting Message Logging Level](#setting-message-logging-level)<br>
[Configuring Location Tracking Updates](#configuring-location-tracking-updates)<br>
[Sending Custom Events](#sending-custom-events)<br>
[Setting a Contact](#setting-a-contact)<br>
[Unsetting a Contact](#unsetting-a-contact)<br>
[Upserting a Contact](#upserting-a-contact)<br>
[Post an Order](#post-an-order)<br>
[Post to Cart](#post-to-cart)<br>
[Event Caching](#event-caching)<br>
[Push Notificatrions](#push-notifications)<br>
[Deep Links](#deep-links)<br>
[Delaying In-App Messages](#delaying-in-app-messages)<br>

## Installation

### Cocoapods

Make sure you have access to CordialSDK gitlab repo. We recommend adding your SSH key to Gitlab. After that, specify CordialSDK in your Podfile:

```
use_frameworks!
pod 'CordialSDK', :git => 'git@gitlab.com:cordialinc/mobile-sdk/ios-sdk.git'
```

Now you can run:

```
pod install
```

This will add the latest version of CordialSDK to your project.

Additionally, in order to take advantage of iOS 10 notification attachments, you will need to create a notification service extension near your main application. In order to do that, create the **Notification Service Extension** target and add `CordialAppExtensions` to it:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
target "The name of the new Notification Service Extension target" do  
    use_frameworks!
    pod 'CordialAppExtensions-Swift', :git => 'git@gitlab.com:cordialinc/mobile-sdk/ios-sdk.git'  
end
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
target "Name of the new Notification Service Extension target" do  
    use_frameworks!
    pod 'CordialAppExtensions-Objective-C', :git => 'git@gitlab.com:cordialinc/mobile-sdk/ios-sdk.git'  
end
```

Ensure that your new target **Notification Service Extension** bundle identifier is prefixed with your app bundle identifier, for example: `yourAppBundleIdentifier.NotificationServiceExtension`. Delete the code that your IDE generated for the new extension and inherit it from `CordialNotificationServiceExtension`:  

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
import CordialAppExtensions_Swift
class NotificationService: CordialNotificationServiceExtension {  
}
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
// NotificationService.h

#import <CordialAppExtensions_Objective_C/CordialAppExtensions_Objective_C.h>

@interface NotificationService : CordialNotificationServiceExtension
@end

// NotificationService.m

#import "NotificationService.h"

@interface NotificationService ()
@end

@implementation NotificationService
@end

```

## Initialize the SDK
In order to initialize the SDK, pass your account key to `CordialApiConfiguration.initialize` method and call it from `AppDelegate.didFinishLaunchingWithOptions`:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialApiConfiguration.shared.initialize(accountKey: "your_account_key", channelKey: "your_channel_key")
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[[CordialApiConfiguration shared] initializeWithAccountKey:@"test_account_key" channelKey:@"test_channel_key"];
```
**Note**: The maximum number of cached events can be set during the initialization step. If not stated, the default limit will be set to 1,000 cached events.

After initializing, the SDK will automatically start tracking internal events as they occur in the application. Those events are:
- App opens and closes
- App installs
- App opened via notification taps
- Receipt of push notification while app is in the foreground

Besides automatic events tracking, the SDK allows developers to call Cordial specific actions, which are typical for client applications. Those actions are:
- Updating a contact
- Posting a cart
- Posting an order
- Sending a custom event

The access point for every action above is the `CordialAPI` class. You can either have a global reference to the object of the class or create an object for every action - that choice is left to the client application.

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let cordialApi = CordialAPI()
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
CordialAPI *cordialAPI = [[CordialAPI alloc] init];
```

## Setting Message Logging Level
You can choose one of four message logging levels: `none`, `all`, `error`, `info`. The logging level is set to `error` by default. Yo can change the logging level during SDK initialization:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialApiConfiguration.shared.osLogManager.setOSLogLevel(.all)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[[[CordialApiConfiguration shared] osLogManager] setLogLevel:logLevelAll];
```

## Configuring Location Tracking Updates
You can expand custom events data by adding geo locations to each custom event. To enable the delivery of location-related events to your app, simply complete these two steps:
1. Add `NSLocationAlwaysAndWhenInUseUsageDescription` and/or `NSLocationWhenInUseUsageDescription` properties to your project `Info.plist` file.
2. Initialize SDK location manager by adding the following to the end of  `AppDelegate.didFinishLaunchingWithOptions`:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialApiConfiguration.shared.initializeLocationManager(desiredAccuracy: kCLLocationAccuracyBest, distanceFilter: kCLDistanceFilterNone, untilTraveled: CLLocationDistanceMax, timeout: CLTimeIntervalMax)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[[CordialApiConfiguration shared] initializeLocationManagerWithDesiredAccuracy:kCLLocationAccuracyBest distanceFilter:kCLDistanceFilterNone untilTraveled:CLLocationDistanceMax timeout:CLTimeIntervalMax];
```
The above example configures the location manager for maximum geo accuracy. To increase phone battery life, you can configure SDK location manager by changing the `desiredAccuracy`, `distanceFilter`, `untilTraveled`, and `timeout` properties.

## Sending Custom Events
Aside from internal events, the SDK allows sending of custom events specific to each app. Those may be, for example, user logged in, discount applied or app preferences updated to name a few. To send a custom event, use the `CordialApi.sendCustomEvent` method:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let properties = ["<property_name>": "<property_value>"]
cordialAPI.sendCustomEvent(eventName: "{custom_event_name}", properties: properties)

```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
NSDictionary *properties = @{ @"<property_name>":@"<property_value>" };
[cordialAPI sendCustomEventWithEventName:@"{custom_event_name}" properties:properties];

```

`properties` - is a dictionary of string keys and string values that can be attached to the event. Can be null.

Example of sending a product browse event:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
```
let properties = ["productName": "Back Off Polo", "SKU": "polo543"]
cordialAPI.sendCustomEvent(eventName: "browse_product", properties: properties)

```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
```
NSDictionary *properties = @{ @"productName" :@"Back Off Polo", @"SKU" :@"polo543" };
[cordialAPI sendCustomEventWithEventName:@"browse_product" properties:properties];
```
Example of sending a category browse event:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
```
let properties = ["categoryName": "Men's"]
cordialAPI.sendCustomEvent(eventName: "browse_category", properties: properties)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
```
NSDictionary *properties = @{ @"categoryName" :@"Men's" };
[cordialAPI sendCustomEventWithEventName:@"browse_category" properties:properties];
```

## Setting a Contact

Every app is assumed to be operating on behalf of a specific contact. Contact is a user of the client application. For example, if Amazon is the client, each user of Amazon who logs in is a contact. Every contact must have a primary key. Naturally, when the app is installed, there is no contact associated with the app as the user might not have logged in yet. In this case, identifying a contact is done via device ID, which is a unique identifier of the iOS device the app is running on.

Every piece of information (internal or custom events, updating a contact, etc.) that is passed by SDK to Cordial backend, has a device ID automatically associated with it. Later, when the user logs into the app and their primary key becomes known, the client application must pass that primary key to the backend by calling the `setContact` method. When the backend receives a contact update with the primary key, it associates the device ID with the primary key of that contact. That association is crucial for effectively using Cordial.

In the event the contact's primary key is unknown, all requests associated with the device ID will be cached until the contact is identified using `setContact`.

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
cordialAPI.setContact(primaryKey: email)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[cordialAPI setContactWithPrimaryKey:email];
```

## Unsetting a Contact

Whenever a contact is disassociated with the application, typically due to a logout event, the Cordial SDK should be notified so that contact generated events are no longer associated with their profile. This is done by calling the `unsetContact` method.

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
cordialAPI.unsetContact()
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[cordialAPI unsetContact];
```

## Upserting a Contact

Contact attributes such as name, age, date of birth, etc. can be updated using the `upsertContact` method. This is an example of updating an already identified contact's `firstName` and `lastName` attributes:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let attributes = ["firstName": "John", "lastName": "Doe"]
cordialAPI.upsertContact(attributes: attributes)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
NSDictionary *attributes = @{ @"firstName":@"John", @"lastName":@"Doe" };
[cordialAPI upsertContactWithAttributes:attributes];
```
`attributes` - dictionary of string keys and strings values attributes that can be attached to a contact. Can be null.

## Post an Order
The orders collection can be updated any time the contact places an order via the app. In order to post an order to Cordial, use the `CordialApi.sendOrder` method:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
сordialAPI.sendContactOrder(order: order)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[cordialAPI sendContactOrderWithOrder:order];
```
`order`- used to specify order parameters such as orderID, storeID, customerID, billing and shipping addresses, etc.

## Post to Cart
Updates to contact's cart can be sent to Cordial by calling the `CordialApi.upsertCart` method:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
сordialAPI.upsertContactCart(cartItems: items)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[cordialAPI upsertContactCartWithCartItems:items];
```

`items` - an array of cart items. Each item is assigned attributes such as SKU, quantity, price and other cart item specific attributes.

## Event Caching
Every request described above is cached in case of failure to post. For example, if the internet is down on the device and an event failed to be delivered to Cordial, the event would be cached by the SDK and its delivery would be retried once the connection is up again.

Cordial SDK limits the number of events that may be cached at any given time. When the limit of cached events is reached, the oldest events are removed and replaced by the incoming events, and will not be resent. By default, the cache limit is set to 1,000 events. Use the following method to modify the default cache limit:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialApiConfiguration.shared.qtyCachedEventQueue = 100
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[CordialApiConfiguration shared].qtyCachedEventQueue = 100;
```

## Events Bulking

In order to optimize devices resource usage, Cordial SDK groups events into bulks and upload them in one request. Each event happened on a device will be added to bulk. The SDK sends a bulk of events in 3 cases:

1. Events limit in bulk is reached. The bulk size is configured via `eventsBulkSize`. Set to 5 by default.
2. The bulk has not been sent for specified time interval. Even if a bulk is not fully populated with events it will be sent every `eventsBulkUploadInterval` in seconds. Bulk upload interval is configured via `eventsBulkUploadInterval`. Set to 30 seconds by default.
3. The application is closed.

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialApiConfiguration.shared.eventsBulkSize = 3
CordialApiConfiguration.shared.eventsBulkUploadInterval = 15
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[CordialApiConfiguration shared].eventsBulkSize = 3;
[CordialApiConfiguration shared].eventsBulkUploadInterval = 15;
```

## Push Notifications
Your application must use Cordial SDK to configure push notifications. Make sure to add `Remote notifications` background mode and `Push Notifications` capability. Make sure you’re not using iOS specific methods to register for push notifications as Cordial SDK would do it automatically. In order to enable push notification delivery and handle notification taps, the code needs the following:

1. Provide Cordial SDK with an instance of the `CordialPushNotificationDelegate` protocol. This should be done in `AppDelegate.didFinishLaunchingWithOptions`:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let pushNotificationHandler = YourImplementationOfTheProtocol()  
CordialApiConfiguration.shared.pushNotificationHandler = pushNotificationHandler
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
YourImplementationOfTheProtocol *pushNotificationHandler = [[YourImplementationOfTheProtocol alloc] init];
[CordialApiConfiguration shared].pushNotificationHandler = pushNotificationHandler;
```

2. To register for receiving push notifications, simply call:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
cordialAPI.registerForPushNotifications()
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[cordialAPI registerForPushNotifications];
```

##  Deep Links 
Cordial SDK allows you to track deep link open events. Two types of deep links are supported: universal links and URL scheme links. In order to allow the SDK to track deep links, make sure to implement the `CordialDeepLinksDelegate` protocol. The protocol contains callbacks that will be called once the app gets the chance to open a deep link.

In the body of the `AppDelegate.didFinishLaunchingWithOptions` function, provide the following implementation:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let cordialDeepLinksHandler = YourImplementationOfCordialDeepLinksHandler()
CordialApiConfiguration.shared.cordialDeepLinksHandler = cordialDeepLinksHandler
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
YourImplementationOfCordialDeepLinksHandler *cordialDeepLinksHandler = [[YourImplementationOfCordialDeepLinksHandler alloc] init];
[CordialApiConfiguration shared].cordialDeepLinksHandler = cordialDeepLinksHandler;
```

## Delaying In-App Messages

Cordial SDK allows application developers to delay displaying of in-app messages. In case if in-app message is delayed it will be displayed the next time the application is opened. There are 3 delay modes in the SDK to control in-app messages display:

1. Show. In-app messages are displayed without delay, which is the default behavior.
2. Delayed Show. Displaying in-app messages is delayed until Delayed Show mode is turned off.
3. Disallowed Controllers. Displaying in-app messages is not allowed on certain screens, which are determined by the application developer.

To switch between modes, call corresponding methods in the CordialApiConfiguration class:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialApiConfiguration.shared.inAppMessageDelayMode.show()
CordialApiConfiguration.shared.inAppMessageDelayMode.delayedShow()
CordialApiConfiguration.shared.inAppMessageDelayMode.disallowedControllers([ClassName.self])
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[[[CordialApiConfiguration shared] inAppMessageDelayMode] show];
[[[CordialApiConfiguration shared] inAppMessageDelayMode] delayedShow];
[[[CordialApiConfiguration shared] inAppMessageDelayMode] disallowedControllers:@[[ClassName class]]];
```

Note, disallowed ViewControllers should inherit from the `InAppMessageDelayViewController` class or otherwise delayed in-app message will be attempted to be shown on next app open.

[Top](#contents)
