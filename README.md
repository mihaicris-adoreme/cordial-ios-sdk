# iOS Cordial SDK Documentation

## Installation

### Cocoapods

Make sure you have access to CordialSDK gitlab repo. We recommend adding your SSH key to Gitlab. After that specify CordialSDK in your Podfile:

```
use_frameworks!
pod 'CordialSDK', :git => 'git@gitlab.com:cordialinc/mobile-sdk/ios-sdk.git'
```

And after that run:

```
pod install
```

This will add the the latest version of CordialSDK to your project.

Additionally, in order to take advantage of iOS 10 notification attachments, you will need to create a notification service extension near your main application. In order to do that create "Notification Service Extension" target and add CordialAppExtensions to it:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
target "<The name of the new Notification Service Extension target>" do  
    use_frameworks!
    pod 'CordialAppExtensions', :git => 'git@gitlab.com:cordialinc/mobile-sdk/ios-sdk.git'  
end
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
target "<The name of the new Notification Service Extension target>" do  
    use_frameworks!
    pod 'CordialAppExtensions_Objective-C', :git => 'git@gitlab.com:cordialinc/mobile-sdk/ios-sdk.git'  
end
```

Make sure that your new target "Notification Service Extension" bundle identifier is prefixed with your app bundle identifier, for example: `yourAppBundleIdentifier.NotificationServiceExtension`. Delete the code that your IDE generated for you for the new extension and inherit it from `CordialNotificationServiceExtension`:  

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
import CordialAppExtensions  
  
class NotificationService: CordialNotificationServiceExtension {  
  
}
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
// NotificationService.h

#import <CordialAppExtensions_Objective_C.h>
#import <CordialAppExtensions_Objective_C/CordialNotificationServiceExtension.h>

@interface NotificationService : CordialNotificationServiceExtension
@end

// NotificationService.m

#import "NotificationService.h"

@interface NotificationService ()
@end

@implementation NotificationService
@end

```

## Initialize SDK
In order to initialize the SDK, pass your account key to `CordialApiConfiguration.initialize` method and call it from `AppDelegate.didFinishLaunchingWithOptions`:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialApiConfiguration.shared.initialize(accountKey: "<your_account_key>", channelKey: "<your_channel_key>")
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[[CordialApiConfiguration shared] initializeWithAccountKey:@"test_account_key" channelKey:@"test_channel_key"];
```
After initialized the SDK will automatically start tracking internal events as they occur in the application. Those events are:
- track application opens and closes
- track installs
- app opened via tapping the push notification
- push notification received while app in the foreground

Besides automatic events tracking, the SDK allows developers to make Cordial specific actions which are typical for client applications. Those actions are:
- updating a contact
- posting a cart
- posting an order
- sending a custom event

The access point for every action above is the `CordialAPI` class. You can either have a global reference to the object of the class or create an object for every action - that choice is left to an application.

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

## Setting a SDK log level
You can choose one of four levels of SDK logs: "none", "all", "error", "info". By it is set to "error". If you need you can change logs level on the SDK initialization step in the following way:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialApiConfiguration.shared.osLogManager.setOSLogLevel(osLogLevel: .all)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[[[CordialApiConfiguration shared] osLogManager] setOSLogLevel: logLevelAll];
```

## Setting a contact

Every app is assumed to be operating on behalf of a specific contact. Contact is a user of the client application. For example, if Amazon is a client, each user of the Amazon who logs in is a contact. Every contact must have a primary key. Naturally that when the app is installed, the is no contact associated with the app as the user might not have logged in yet. In this case identifying a contact is done via device id, which is a unique identifier of the iOS device the app is running on. Every piece of information (internal or custom events, updating a contact etc) that is passed by SDK to Cordial backend has a device id automatically associated with it. Later, when the user logs into the app and his primary key becomes known, the client application must pass that primary key to the backend via calling the `setContact` method. When the backend receives a contact update with the primary key it associates the device id with the primary key of a contact. That association is crucial to make effective use of Cordial.

When there is no contact associated with the SDK, all requests that the SDK makes to Cordial are cached until the contact becomes known (that is until `setContact` method is called).

setContact usage:

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

## Unsetting a contact

Whenever a contact is disassociated with the application, which typically happens on user log out, the SDK should be told so so that it stops associating all client generated events with the contact who is no logged in. This is done via `unsetContact` method:

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

## Upserting a contact

Each contact has a set of attributes associated with it. To update values of the attributes of the set contact, `upsertContact` method should be used. For example, if there are `firstName` and `lastName` attributes updating their values will be done in the following way:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let attributes = ["firstName":"John", "lastName":"Doe"]
let upsertContactRequest = UpsertContactRequest(attributes: attributes)
cordialAPI.upsertContact(upsertContactRequest: upsertContactRequest)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
NSDictionary *attributes = @{ @"firstName" :@"John", @"lastName" :@"Doe" };
UpsertContactRequest *upsertContactRequest = [[UpsertContactRequest alloc] initWithAttributes:attributes];
[cordialAPI upsertContactWithUpsertContactRequest:upsertContactRequest];
```

## Send custom events
Besides internal events, the SDK allows to send custom events specific to each app. Those may be, for example, user logged in, discount applied or app preferences updated to name a few. To send custom event, use the `CordialApi.sendCustomEvent` method:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let request = SendCustomEventRequest(eventName: "{custom_event_name}", properties: ["<property_name>": "<property_value>"])  
cordialApi.sendCustomEvent(sendCustomEventRequest: request)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
SendCustomEventRequest *request = [[SendCustomEventRequest alloc] initWithEventName:@"{custom_event_name}" properties:@{ @"<property_name>" :@"<property_value>" }];
[cordialAPI sendCustomEventWithSendCustomEventRequest:request];
```

`properties` - is a dictionary of string keys and string values that can be attached to the event. Can be nil.

## Configuring SDK to track location updates
You can expand custom events data by adding geo locations to each custom event. To enable this feature set SDK location manager through these two steps:
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
Example above has configured location manager for maximum geo accuracy. To increase phone battery life you can configure SDK location manager by changing `desiredAccuracy`, `distanceFilter`, `untilTraveled`, `timeout` properties.

## Post an order
When an order is posted in client application, the app should notify Cordial about that. In order to post an order to Cordial, use the `CordialApi.sendOrder` method:

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

The `order` object specifies things like orderId, storeId, customerId, billing and shipping addresses. 

## Post a cart
When a user updates the cart, the app should notify the Cordial backed by calling the `CordialApi.upsertCart` method:

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

`items` is an array of, well, cart items. Each items has items sku, quantity, price and other cart item specific attributes.

## Caching
Every request described above is cached in case of its failure. For example, if internet is down on the device and an event failed to be delivered to Cordial, the event would be cached by the SDK and its delivery would be retried once internet connection is up again. 

Events cache has quantity limits of cached events. By default this value is equal to 1000. If you want you can change cached events quantity limit to any value on the SDK initialization step in the following way:

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

## Push notifications
The application should use Cordial SDK to configure push notifications. Make sure you’re not using iOS specific methods to register for push notifications as Cordial SDK would do it automatically. In order to handle push notification delivered and handle taps on them, the code needs to do 3 things:
1. Provide Cordial SDK with an instance of the `CordialPushNotificationDelegate` protocol. Do so in `AppDelegate.didFinishLaunchingWithOptions`:

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

2. Inherit `AppDelegate` from `CordialAppDelegate` for Swift or from `CordialObjcAppDelegate` if you need Objective-C implementation:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
class AppDelegate: CordialAppDelegate {

var window: UIWindow?

...

}
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
//  AppDelegate.h

#import <CordialSDK/CordialSDK-Swift.h>
#import "CordialSDK/CordialObjcAppDelegate.h"

@interface AppDelegate : CordialObjcAppDelegate

...

@end

//  AppDelegate.m

@implementation AppDelegate

@dynamic window; 

...

@end
```

3. To register for receiving push notifications in your application call:

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

##  Deep links 
The SDK allows to track opening deep links. Two types of deep links are supported: universal links and URL scheme links. 
In order to allow the SDK to track opening deep links make sure to implement any of the two or both protocols, each for corresponding type of deep links: `CordialContinueRestorationDelegate` for universal links and `CordialOpenOptionsDelegate` for URL scheme deep links. The protocols contain callbacks that will be called once the app gets a chance of opening a deep link.

1. In the body of function `AppDelegate.didFinishLaunchingWithOptions` provide implementation for one or both protocols:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let continueRestorationHandler = YourImplementationOfCordialContinueRestorationHandler()
let openOptionsHandler = YourImplementationOfCordialOpenOptionsHandler()

CordialApiConfiguration.shared.continueRestorationHandler = continueRestorationHandler
CordialApiConfiguration.shared.openOptionsHandler = openOptionsHandler
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
YourImplementationOfCordialContinueRestorationHandler *continueRestorationHandler = [[YourImplementationOfCordialContinueRestorationHandler alloc] init];
YourImplementationOfCordialOpenOptionsHandler *openOptionsHandler = [[YourImplementationOfCordialOpenOptionsHandler alloc] init];

[CordialApiConfiguration shared].continueRestorationHandler = continueRestorationHandler;
[CordialApiConfiguration shared].openOptionsHandler = openOptionsHandler;
```

2. Inherit  `AppDelegate` from `CordialAppDelegate` for Swift or from `CordialObjcAppDelegate` for Objective-C. See details in Push Notification section above.
