# iOS Cordial SDK Documentation
## Contents

[Installation](#installation)<br>
[Initialize the SDK](#initialize-the-sdk)<br>
[Push Notifications](#push-notifications)<br>
[Method Swizzling](#method-swizzling)<br>
[Multiple Push Notification Providers](#multiple-push-notification-providers)<br>
[Post a Cart](#post-a-cart)<br>
[Post an Order](#post-an-order)<br>
[Deep Links](#deep-links)<br>
[Contacts](#contacts)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[Setting a Contact](#setting-a-contact)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[Unsetting a Contact](#unsetting-a-contact)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[Updating Attributes and Lists Memberships](#updating-attributes-and-lists-memberships)<br>
[Events](#events)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[Sending Custom Events](#sending-custom-events)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[Tracking Internal Events](#tracking-internal-events)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[Event Caching](#event-caching)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[Events Bulking](#events-bulking)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[Events Flushing](#events-flushing)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[Configuring Location Tracking Updates](#configuring-location-tracking-updates)<br>
[In-App Messages](#in-app-messages)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[In-App Messaging Link Actions](#in-app-messaging-link-actions)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[Delaying In-App Messages](#delaying-in-app-messages)<br>
[Inbox Messages](#inbox-messages)<br>
[Message Attribution](#message-attribution)<br>
[SwiftUI apps](#swiftui-apps)<br>

# Installation

## Swift Package Manager

For adding CordialSDK to your project via Swift Package Manager use this repository: `git@gitlab.com:cordialinc/mobile-sdk/ios-sdk.git`

## Cocoapods

Make sure you have access to CordialSDK gitlab repo. We recommend adding your SSH key to Gitlab. After that, specify CordialSDK in your Podfile:

```
use_frameworks!
pod 'CordialSDK'
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
    pod 'CordialAppExtensions-Swift'  
end
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
target "Name of the new Notification Service Extension target" do  
    use_frameworks!
    pod 'CordialAppExtensions-Objective-C'  
end
```

Ensure that your new target **Notification Service Extension** bundle identifier is prefixed with your app bundle identifier, for example: `yourAppBundleIdentifier.NotificationServiceExtension`. Delete the code that your IDE generated for the new extension and inherit it from `CordialNotificationServiceExtension`:  

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
[[CordialApiConfiguration shared] initializeWithAccountKey:@"your_account_key" channelKey:@"your_channel_key" eventsStreamURL:NULL messageHubURL:NULL];
```

To change base host url, pass the new value as `eventsStreamURL` param via the `CordialApiConfiguration.initialize` method:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialApiConfiguration.shared.initialize(accountKey: "your_account_key", channelKey: "your_channel_key", eventsStreamURL: "your_events_stream_URL")
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[[CordialApiConfiguration shared] initializeWithAccountKey:@"your_account_key" channelKey:@"your_channel_key" eventsStreamURL:@"your_events_stream_URL" messageHubURL:NULL];
```

To change message hub host url, pass the new value as `messageHubURL` param next to `eventsStreamURL` param via the `CordialApiConfiguration.initialize` method:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialApiConfiguration.shared.initialize(accountKey: "your_account_key", channelKey: "your_channel_key", eventsStreamURL: "your_events_stream_URL", messageHubURL: "your_message_hub_URL")
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[[CordialApiConfiguration shared] initializeWithAccountKey:@"your_account_key" channelKey:@"your_channel_key" eventsStreamURL:@"your_events_stream_URL" messageHubURL:@"your_message_hub_URL"];
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

#### Setting Message Logging Level
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

## Push Notifications

Your application can use Cordial SDK to configure push notifications.

Make sure to add `Remote notifications` background mode and `Push Notifications` capability. In order to enable push notification delivery and handle notification taps, the code needs the following:

1. Register for receiving push notifications:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
cordialAPI.registerForPushNotifications(options: [.alert, .sound, .badge])
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
#import <UserNotifications/UserNotifications.h>

[cordialAPI registerForPushNotificationsWithOptions:UNAuthorizationOptionAlert|UNAuthorizationOptionSound|UNAuthorizationOptionBadge];
```

2. Optionally provide Cordial SDK with an instance of the `CordialPushNotificationDelegate` protocol. This should be done in `AppDelegate.didFinishLaunchingWithOptions`:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let pushNotificationHandler = YourImplementationOfTheProtocol()  
CordialApiConfiguration.shared.pushNotificationDelegate = pushNotificationHandler
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
YourImplementationOfTheProtocol *pushNotificationHandler = [[YourImplementationOfTheProtocol alloc] init];
[CordialApiConfiguration shared].pushNotificationDelegate = pushNotificationHandler;
```

3. Let the SDK know when your app receives a silent push notification. Silent push notifications are used for notifying the app of a new in-app or inbox message:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialPushNotificationHandler().processSilentPushDelivery(userInfo: userInfo)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[[[CordialPushNotificationHandler alloc] init] processSilentPushDeliveryWithUserInfo:userInfo];
```

## Method Swizzling

Cordial SDK does swizzling in three areas:

- Registering for and receiving push notifications
- Handling deep links
- Processing events from completing a URL session request

Swizzling allows minimum SDK configuration by the container app. Developers who prefer not to use swizzling can disable swizzling for these areas individually. In case swizzling is disabled for an area, there are methods in the SDK to be called by the app after specific events in the app occur.

If swizzling for the three areas is enabled is controlled by three fields:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialApiConfiguration.shared.pushesConfiguration = .APP
CordialApiConfiguration.shared.deepLinksConfiguration = .SDK
CordialApiConfiguration.shared.backgroundURLSessionConfiguration = .SDK

```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[CordialApiConfiguration shared].pushesConfiguration = CordialPushNotificationConfigurationTypeAPP;
[CordialApiConfiguration shared].deepLinksConfiguration = CordialDeepLinksConfigurationTypeSDK;
[CordialApiConfiguration shared].backgroundURLSessionConfiguration = CordialURLSessionConfigurationTypeSDK;
```

The value can be either `SDK` or `APP`. To switch swizzling for an area off, set the corresponding value to `APP`, meaning that the app will take care of passing the required data to the SDK, instead of SDK doing it itself.

Below are the details on how to disable swizzling for each specific area

#### Disable swizzling for registering and receiving push notifications

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialApiConfiguration.shared.pushesConfiguration = .APP

```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[CordialApiConfiguration shared].pushesConfiguration = CordialPushNotificationConfigurationTypeAPP;
```

In order to disable swizzling for registering and receiving push notifications see [Multiple Push Notification Providers](#multiple-push-notification-providers).

#### Disable swizzling for handling deep links

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialApiConfiguration.shared.deepLinksConfiguration = .APP

```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[CordialApiConfiguration shared].deepLinksConfiguration = CordialDeepLinksConfigurationTypeAPP;
```

Depending on iOS version and if your app use scenes, you should call corresponding method of the SDK.

In case the app is iOS 13 and greater and the app uses scenes, call the SDK from these two methods:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
// scene(_:continue:)
CordialDeepLinksConfigurationHandler().processSceneContinue(userActivity: userActivity, scene: scene)

// scene(_:openURLContexts:)
CordialDeepLinksConfigurationHandler().processSceneOpenURLContexts(URLContexts: URLContexts, scene: scene)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
// scene(_:continue:)
[[CordialDeepLinksConfigurationHandler alloc] processSceneContinueWithUserActivity:userActivity scene:scene];

// scene(_:openURLContexts:)
[[CordialDeepLinksConfigurationHandler alloc] processSceneOpenURLContextsWithURLContexts:URLContexts scene:scene];
```

Otherwise call the SDK from these methods:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
// application(_:continue:restorationHandler:)
CordialDeepLinksConfigurationHandler().processAppContinueRestorationHandler(userActivity: userActivity)

// application(_:open:options:)
CordialDeepLinksConfigurationHandler().processAppOpenOptions(url: url)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
// application(_:continue:restorationHandler:)
[[CordialDeepLinksConfigurationHandler alloc] processAppContinueRestorationHandlerWithUserActivity:userActivity];

// application(_:open:options:)
[[CordialDeepLinksConfigurationHandler alloc] processAppOpenOptionsWithUrl:url];
```

#### Disable swizzling for processing events from completing a URL session request

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialApiConfiguration.shared.backgroundURLSessionConfiguration = .APP
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[CordialApiConfiguration shared].backgroundURLSessionConfiguration = CordialURLSessionConfigurationTypeAPP;
```

To turn off swizzling for processing events from completing a URL session, call `processURLSessionCompletionHandler` from your `application(_:handleEventsForBackgroundURLSession:completionHandler:)` method:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let cordialURLSessionConfigurationHandler = CordialURLSessionConfigurationHandler()
if cordialURLSessionConfigurationHandler.isCordialURLSession(identifier: identifier) {
    cordialURLSessionConfigurationHandler.processURLSessionCompletionHandler(identifier: identifier, completionHandler: completionHandler)
}
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
CordialURLSessionConfigurationHandler *cordialURLSessionConfigurationHandler = [CordialURLSessionConfigurationHandler alloc];
if ([cordialURLSessionConfigurationHandler isCordialURLSessionWithIdentifier:identifier]) {
    [cordialURLSessionConfigurationHandler processURLSessionCompletionHandlerWithIdentifier:identifier completionHandler:completionHandler];
}
```

## Multiple Push Notification Providers
Cordial SDK supports multiple push notification providers in your app if the app uses `UserNotifications` framework (available since iOS 10). 

It allows to use several notification providers in a single app simultaneously. This requires your application to configure itself for push notifications and let Cordial SDK display and track notifications that were sent by Cordial. To allow Cordial SDK to display and track push notifications sent by Cordial, the application should send APNS token to Cordial SDK once received and use a specific piece of code shown below in several parts of your application. 

By default Cordial SDK is set up as the only push notification provider for your application. This behavior can be changed using `pushesConfiguration` option which can take one of the two values `SDK` or `APP`.  In order to enable multiple notification providers set `CordialApiConfiguration.pushesConfiguration` to `APP` and call it from `AppDelegate.didFinishLaunchingWithOptions`:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialApiConfiguration.shared.pushesConfiguration = .APP
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[CordialApiConfiguration shared].pushesConfiguration = CordialPushNotificationConfigurationTypeAPP;
```

After enabling multiple push notification providers support the application needs to know if a push notification is from Cordial. To check if push notification is from Cordial use `isCordialMessage` function:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
if CordialPushNotificationHandler().isCordialMessage(userInfo: userInfo) {
    // Any Cordial push notification handler call
}

```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
if ([[[CordialPushNotificationHandler alloc] init] isCordialMessageWithUserInfo:userInfo]) {
    // Any Cordial push notification handler call
}
```

After enabling multiple push notification providers the app should pass an APNS token to the SDK once it’s received and start passing push notifications sent by Cordial to the SDK. Note, it is really important to pass the token otherwise the SDK will not be tracking any user behaviour on the device.

To handle Cordial push notifications after enabling multiple notification providers support the app needs to do three additional steps:

1. Pass push notification token to the Cordial SDK:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialPushNotificationHandler().processNewPushNotificationToken(deviceToken: deviceToken)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[[[CordialPushNotificationHandler alloc] init] processNewPushNotificationTokenWithDeviceToken:deviceToken];
```

2. Call method `processAppOpenViaPushNotificationTap` if app has been open via push notification tap:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialPushNotificationHandler().processAppOpenViaPushNotificationTap(userInfo: userInfo, completionHandler: completionHandler)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[[[CordialPushNotificationHandler alloc] init] processAppOpenViaPushNotificationTapWithUserInfo:userInfo completionHandler:completionHandler];
```

3. Call method `processNotificationDeliveryInForeground` if push notification has been foreground delivered:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialPushNotificationHandler().processNotificationDeliveryInForeground(userInfo: userInfo, completionHandler: completionHandler)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[[[CordialPushNotificationHandler alloc] init] processNotificationDeliveryInForegroundWithUserInfo:userInfo completionHandler:completionHandler];
```

## Post a Cart
Updates to contact's cart can be sent to Cordial by calling the `CordialApi.upsertContactCart` method:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
сordialAPI.upsertContactCart(cartItems: cartItems)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[cordialAPI upsertContactCartWithCartItems:cartItems];
```

`cartItems` - an array of cart items. Each item is assigned attributes such as SKU, quantity, price and other cart item specific attributes:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let cartItem = CartItem(productID: "productID", name: "productName", sku: "productSKU", category: "productCategory", url: nil, itemDescription: nil, qty: 1, itemPrice: 20, salePrice: 20, attr: nil, images: nil, properties: nil)

let cartItems = [cartItem]
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
NSNumber *qty = [NSNumber numberWithInteger:1];
NSNumber *price = [NSNumber numberWithDouble:20.00];

CartItem *cartItem = [[CartItem alloc] initWithProductID:@"productID" name:@"productName" sku:@"productSKU" category:@"productCategory" url:nil itemDescription:nil qtyNumber:qty itemPriceNumber:price salePriceNumber:price attr:nil images:nil properties:nil];

NSArray *cartItems = [[NSArray alloc] initWithObjects:cartItem, nil];
```

You can also set the timestamp by passing the instance of the `Date` class to the `setTimestamp` method, otherwise the `timestamp` will be initialized when the `CartItem` object is created.

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
cartItem.seTimestamp(date: Date())
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
NSDate *date = [[NSDate alloc] init];
[cartItem seTimestampWithDate:date];
```

## Post an Order
The orders collection can be updated any time the contact places an order via the app. In order to post an order to Cordial, use the `CordialApi.sendContactOrder` method:

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
`order`- used to specify order parameters such as orderID, storeID, customerID, billing and shipping addresses, etc:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let shippingAddress = Address(name: "shippingAddressName", address: "shippingAddress", city: "shippingAddressCity", state: "shippingAddressState", postalCode: "shippingAddressPostalCode", country: "shippingAddressCountry")

let billingAddress = Address(name: "billingAddressName", address: "billingAddress", city: "billingAddressCity", state: "billingAddressState", postalCode: "billingAddressPostalCode", country: "billingAddressCountry")

let cartItem = CartItem(productID: "productID", name: "productName", sku: "productSKU", category: "productCategory", url: nil, itemDescription: nil, qty: 1, itemPrice: 20, salePrice: 20, attr: nil, images: nil, properties: nil)

let cartItems = [cartItem]

let orderID = UUID().uuidString

let order = Order(orderID: orderID, status: "orderStatus", storeID: "storeID", customerID: "customerID", shippingAddress: shippingAddress, billingAddress: billingAddress, items: cartItems, tax: nil, shippingAndHandling: nil, properties: nil)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
Address *shippingAddress = [[Address alloc] initWithName:@"shippingAddressName" address:@"shippingAddress" city:@"shippingAddressCity" state:@"shippingAddressState" postalCode:@"shippingAddressPostalCode" country:@"shippingAddressCountry"];

Address *billingAddress = [[Address alloc] initWithName:@"billingAddressName" address:@"billingAddress" city:@"billingAddressCity" state:@"billingAddressState" postalCode:@"billingAddressPostalCode" country:@"billingAddressCountry"];

NSNumber *qty = [NSNumber numberWithInteger:1];
NSNumber *price = [NSNumber numberWithDouble:20.00];

CartItem *cartItem = [[CartItem alloc] initWithProductID:@"productID" name:@"productName" sku:@"productSKU" category:@"productCategory" url:nil itemDescription:nil qtyNumber:qty itemPriceNumber:price salePriceNumber:price attr:nil images:nil properties:nil];

NSArray *cartItems = [[NSArray alloc] initWithObjects:cartItem, nil];

NSString *orderID = [[NSUUID alloc] init].UUIDString;

Order *order = [[Order alloc] initWithOrderID:orderID status:@"orderStatus" storeID:@"storeID" customerID:@"customerID" shippingAddress:shippingAddress billingAddress:billingAddress items:cartItems taxNumber:nil shippingAndHandling:nil properties:nil];
```

You can also set the `purchaseDate` by passing the instance of the `Date` class to the `setPurchaseDate` method, otherwise the `purchaseDate` will be initialized when the `Order` object is created.

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
order.setPurchaseDate(date: Date())
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
NSDate *date = [[NSDate alloc] init];
[order setPurchaseDateWithDate:date];
```

##  Deep Links 
Cordial SDK allows you to track deep link open events. Two types of deep links are supported: universal links and URL scheme links. In order to allow the SDK to track deep links, make sure to implement the `CordialDeepLinksDelegate` protocol. The protocol contains callbacks that will be called once the app gets the chance to open a deep link.

In the body of the `AppDelegate.didFinishLaunchingWithOptions` function, provide the following implementation:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let cordialDeepLinksHandler = YourImplementationOfCordialDeepLinksHandler()
CordialApiConfiguration.shared.cordialDeepLinksDelegate = cordialDeepLinksHandler
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
YourImplementationOfCordialDeepLinksHandler *cordialDeepLinksHandler = [[YourImplementationOfCordialDeepLinksHandler alloc] init];
[CordialApiConfiguration shared].cordialDeepLinksDelegate = cordialDeepLinksHandler;
```

#### Have the SDK opening deep links unknown to the application
In case the SDK calls `openDeepLink` function at the protocol `CordialDeepLinksDelegate` with a deep link url that the application doesn't know how to handle, the app should ask the SDK to open the deep link in a web browser. The application can open the deep link in a web browser itself but in this case revenue attribution flow may be lost. In order to tell the SDK to open an unknown deep link, call `completionHandler` callback in your `openDeepLink` method, passing it `OPEN_IN_BROWSER` option:
&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
completionHandler(.OPEN_IN_BROWSER)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
completionHandler(CordialDeepLinkActionTypeOPEN_IN_BROWSER);
```

#### Opening deep links from a killed application

When an application is killed the process the iOS starts the app makes it impossible for the SDK to determine that the app is opened via clicking a deep link outside the app. To allow SDK to open deep links correcly and track its corresponding events when the app is killed, the application will need to let the SDK know that it is being started via opening a deep link. To do so insert the following snippets of code to your application.

Since iOS 13 if the application uses scenes:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialDeepLinksAPI().openSceneDelegateUniversalLink(scene: scene, userActivity: userActivity)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[[CordialDeepLinksAPI alloc] openSceneDelegateUniversalLinkWithScene:scene userActivity:userActivity];
```

Since iOS 13 if the application does not use scenes:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialDeepLinksAPI().openAppDelegateUniversalLink(userActivity: userActivity)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[[CordialDeepLinksAPI alloc] openAppDelegateUniversalLinkWithUserActivity:userActivity];
```

#### Configure vanity domains for link tracking

In order for SDK to support opening deep links with tracking on the SDK should be configured with links vanity domain. Vanity domain to be provided by Cordial.

In order to configure the SDK with a vanity domain:

1. You app must add the domain to the list of active domains.

2. The domain should be added to SDK as a vanity domain:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialApiConfiguration.shared.vanityDomains = ["vanity.domain.com"]
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[CordialApiConfiguration shared].vanityDomains = @[@"vanity.domain.com"];
```

#### Opening deep links received from Cordial

In case the app receives a deep link from Cordial, for example as part of inbox message metadata, instead of trying to process the deep link itself, the app should open it via Cordial SDK. Cordial SDK will do regular deep link processing that is required when opening the deep link and pass the final deep link to `CordialDeepLinksDelegate`. Deep link processing includes:

- Send system deep link open event to Cordial
- Unwrap deep link in case it is shortened or wrapped up for click tracking

To ask the SDK to open deep links received from Cordial use `openDeepLink` function on `CordialAPI`:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let url = URL(string: "https://appdomain.com/link")!
cordialAPI.openDeepLink(url: url)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
NSURL *url = [NSURL URLWithString: @"https://appdomain.com/link"];
[cordialAPI openDeepLinkWithUrl:url];
```

## Contacts

### Setting a Contact

Every app is assumed to be operating on behalf of a specific contact. Contact is a user of the client application. For example, if Amazon is the client, each user of Amazon who logs in is a contact. Every contact must have a primary key. Naturally, when the app is installed, there is no contact associated with the app as the user might not have logged in yet. In this case, identifying a contact is done via device ID, which is a unique identifier of the iOS device the app is running on.

Every piece of information (internal or custom events, updating a contact, etc.) that is passed by SDK to Cordial backend, has a device ID automatically associated with it. Later, when the user logs into the app and their primary key becomes known, the client application must pass that primary key to the backend by calling the `setContact` method. When the backend receives a contact update with the primary key, it associates the device ID with the primary key of that contact. That association is crucial for effectively using Cordial.

There are two states in the SDK: `Logged in` and `Logged out`. The difference is that the `Logged in` state sends requests and receives push messages, while the `Logged out` state caches requests and does not receive push messages. The `Logged out` state is described in "Unsetting a contact" section. The `Logged in` state can be with and without a primary key. By default, the SDK is automatically set to `Logged in` state without primary key.

`setContact` with primary key usage:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
cordialAPI.setContact(primaryKey: "foo@example.com")
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[cordialAPI setContactWithPrimaryKey: @"foo@example.com"];
```

`setContact` with secondary key usage:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
cordialAPI.setContact(primaryKey: "email:foo@example.com")
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[cordialAPI setContactWithPrimaryKey: @"email:foo@example.com"];
```

### Unsetting a Contact

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

### Updating Attributes and Lists Memberships
In order to udpate a contact's attributes, call the upsertContact method passing it new attributes values, for example:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
var attributes = Dictionary<String, AttributeValue>()

attributes[“name”] = StringValue(“Jon Doe”)
attributes[“employed”] = BooleanValue(true)
attributes[“age”] = NumericValue(32)
attributes[“children”] = ArrayValue([“Sofia", “Jack”])

cordialAPI.upsertContact(attributes: attributes)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
StringValue *name = [[StringValue alloc] init:@"Jon Doe"];
BooleanValue *employed = [[BooleanValue alloc] init:TRUE];
NumericValue *age = [[NumericValue alloc] initWithIntValue:32];
ArrayValue *children = [[ArrayValue alloc] init:@[@"Sofia", @"Jack"]];

NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
[attributes setObject:name forKey:@"name"];
[attributes setObject:employed forKey:@"employed"];
[attributes setObject:age forKey:@"age"];
[attributes setObject:children forKey:@"children"];

[cordialAPI upsertContactWithAttributes:attributes];
```
Adding a contact to a list is done via passing an attribute update with list name as a key and boolean as a value. The boolean means if the contact is added to or removed from the list. The following code makes sure the contact is added to `list1` and removed from `list2`:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let attributes = ["list1": BooleanValue(true), "list2": BooleanValue(false)]
cordialAPI.upsertContact(attributes: attributes)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
BooleanValue *trueValue = [[BooleanValue alloc] init:TRUE];
BooleanValue *falseValue = [[BooleanValue alloc] init:FALSE];

NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
[attributes setObject:trueValue forKey:@"list1"];
[attributes setObject:falseValue forKey:@"list2"];

[cordialAPI upsertContactWithAttributes:attributes];
```

## Events

### Sending Custom Events
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
NSDictionary *properties = @{ @"productName":@"Back Off Polo", @"SKU":@"polo543" };
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
NSDictionary *properties = @{ @"categoryName":@"Men's" };
[cordialAPI sendCustomEventWithEventName:@"browse_category" properties:properties];
```

### Tracking Internal Events

To attached custom  `properties`  to internal system events set property `systemEventsProperties` after initialization CordilSDK.

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
```
CordialApiConfiguration.shared.systemEventsProperties = ["<property name>": "<property value>"]
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
```
[CordialApiConfiguration shared].systemEventsProperties = @{ @"<property name>":@"<property value>" };
```

### Event Caching
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

### Events Bulking

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

### Events Flushing

The SDK allows to send all cached events immediately. This is done by calling the `flushEvents` method:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
cordialAPI.flushEvents(reason: "Flush events from the app")
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[cordialAPI flushEventsWithReason:@"Flush events from the app"];
```

### Configuring Location Tracking Updates
You can expand custom events data by setting geo locations to be sent with each custom event. To enable the delivery of location-related events to your app, simply complete these two steps::
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

## In-App Messages

### In-App Messaging Link Actions

Cordial SDK can handle actions from a designated HTML object. Using `crdlAction` function you can create buttons that deep link to specific content within your app or send custom events such as cart, browse, discount_applied, and dismissed. Using `crdlCaptureAllInputs` function you can capture inputs from input and select html elements and send them as properties of specified custom event. 

To be able to handle deep links from an in-app message, see [Deep Links](#deep-links) section.

For more information, see  [Cordial Knowledge Base](https://support.cordial.com/hc/en-us/articles/360046096752#linkActions).

### Delaying In-App Messages

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

## Inbox Messages

To work with inbox messages you will have to use the `InboxMessageAPI` class. It is the entry point to all inbox messages related functionality. The API supports the following operations:

#### Fetch all inbox messages for currently logged in contact

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let pageRequest = PageRequest(page: 1, size: 10) 
CordialInboxMessageAPI().fetchInboxMessages(pageRequest: pageRequest, onSuccess: { inboxPage in
    // your code
}, onFailure: { error in
    // your code
})
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
PageRequest *pageRequest = [[PageRequest alloc] initWithPage:1 size:10];
[[[CordialInboxMessageAPI alloc] init] fetchInboxMessagesWithPageRequest:pageRequest inboxFilter:nil onSuccess:^(InboxPage *inboxPage) {
    // your code
} onFailure:^(NSString *error) {
    // your code
}];
``` 

Response is an `InboxPage` object which contains pagination parameters. `InboxPage` property content is an array of `InboxMessage` objects. `InboxMessage` represents one inbox message, containing its `mcID`, `metadata`, if the message is read and when it was sent. The `metadata` is a special field which is populated in the admin panel when creating message content. It is specific to each message and should contain the data to be used when a page of inbox messages is loaded. For example, it may contain image thumbnail, title and subtitle to generate a preview without loading inbox message content.

To filter inbox messages, pass an `InboxFilter` instance to the `fetchInboxMessages` method:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let pageRequest = PageRequest(page: 1, size: 10) 
let fromDate = Date()
let toDate = Date()
let inboxFilter = InboxFilter(isRead: .yes, fromDate: fromDate, toDate: toDate)
CordialInboxMessageAPI().fetchInboxMessages(pageRequest: pageRequest, inboxFilter: inboxFilter, onSuccess: { inboxPage in
    // your code
}, onFailure: { error in
    // your code
})
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
PageRequest *pageRequest = [[PageRequest alloc] initWithPage:1 size:10];
NSDate *fromDate = [[NSDate alloc] init];
NSDate *toDate = [[NSDate alloc] init];
InboxFilter *inboxFilter = [[InboxFilter alloc] initWithIsRead:InboxFilterIsReadTypeYes fromDate:fromDate toDate:toDate];
[[[CordialInboxMessageAPI alloc] init] fetchInboxMessagesWithPageRequest:pageRequest inboxFilter:inboxFilter onSuccess:^(InboxPage *inboxPage) {
    // your code
} onFailure:^(NSString *error) {
    // your code
}];
``` 

`InboxFilter` contains the following filter parameters:

    If the inbox message is read
    If the inbox message was sent before the specified date
    If the inbox message was sent after the specified date

#### Send up an inbox message is read event. 

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let mcID = "example_mc_id"
InboxMessageAPI().sendInboxMessageReadEvent(mcID: mcID)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
NSString *mcID = @"example_mc_id";
[[[InboxMessageAPI alloc] init] sendInboxMessageReadEventWithMcID:mcID];
```

This is the method to be called to signal a message is read by the user and should be triggered every time a contact reads (or opens) a message.

#### Mark a message as read/unread

This operations actually marks a message as read or unread which toggles the `isRead` flag on the corresponding `InboxMessage` object.

To mark messages as read:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let mcIDs = ["example_mc_id_1", "example_mc_id_2"]
InboxMessageAPI().markInboxMessagesRead(mcIDs: mcIDs)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
NSArray *mcIDs = @[@"example_mc_id_1", @"example_mc_id_2"];
[[[InboxMessageAPI alloc] init] markInboxMessagesReadWithMcIDs:mcIDs];
```

#### To mark messages as unread:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let mcIDs = ["example_mc_id_1", "example_mc_id_2"]
InboxMessageAPI().markInboxMessagesUnread(mcIDs: mcIDs)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
NSArray *mcIDs = @[@"example_mc_id_1", @"example_mc_id_2"];
[[[InboxMessageAPI alloc] init] markInboxMessagesUnreadWithMcIDs:mcIDs];
```

#### To delete an inbox message:

To remove an inbox message from user's inbox, call

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let mcID = "example_mc_id"
InboxMessageAPI().deleteInboxMessage(mcID: mcID)
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
NSString *mcID = @"example_mc_id";
[[[InboxMessageAPI alloc] init] deleteInboxMessageWithMcID:mcID];
```

#### Notifications about new incoming inbox message

The SDK can notify when a new inbox message has been delivered to the device. In order to be notified set a `InboxMessageDelegate`:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
let inboxMessageHandler = YourImplementationOfInboxMessageDelegate()
CordialApiConfiguration.shared.inboxMessageDelegate = inboxMessageHandler
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
YourImplementationOfInboxMessageDelegate *inboxMessageHandler = [[YourImplementationOfInboxMessageDelegate alloc] init];
[CordialApiConfiguration shared].inboxMessageDelegate = inboxMessageHandler;
```

#### Inbox messages cache

The SDK caches inbox messages in order to limit the number of requests the SDK makes. To control the size of the cache so that it doesn't grow unlimited the SDK configures the cache with two values:

- max size of each inbox message in bytes. Messages bigger than max size will not be cached. Default value is 200 kB
- total cache size in bytes. As soon as the cache reaches it max size, the SDK will replace the least used inbox messages with the new ones. Default value is 10 MB.

To override default values, set them via:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
CordialApiConfiguration.shared.inboxMessageCache.maxCacheSize = 10 * 1024 * 1024 // 10 MB
CordialApiConfiguration.shared.inboxMessageCache.maxCachableMessageSize = 200 * 1024 // 200 kB
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[[CordialApiConfiguration shared] inboxMessageCache].maxCacheSize = 10 * 1024 * 1024; // 10 MB
[[CordialApiConfiguration shared] inboxMessageCache].maxCachableMessageSize = 200 * 1024; // 200 kB
```

## Message Attribution

To attribute future events the SDK sends to a message, a client app should explicitly set `mcID` of the message. Note, this typically should be done for inbox messages only as in-app messages and push notifications set `mcID` automatically when a user interacts with the message:

&nbsp;&nbsp;&nbsp;&nbsp;Swift:
___
```
cordialAPI.setCurrentMcID(mcID: "mcID")
```
&nbsp;&nbsp;&nbsp;&nbsp;Objective-C:
___
```
[cordialAPI setCurrentMcIDWithMcID:@"mcID"];
```

# SwiftUI apps

Cordial SDK supports SwiftUI apps. All sections above still hold for SwiftUI apps except deep links which are described below. Additionally, the SDK adds several classes to make it easier to work with it from SwiftUI app. 

## Initialization

Initialization of the SDK is done in the same way as it is for UIKit application with one difference that it is possible to run SDK initialization code within `init` method of your `App` class.

## Deep links

To handle deep links in a SwiftUI app, subscribe your views to `CordialSwiftUIDeepLinksPublisher.deepLinks` `PassthroughSubject`. The subject will publish deep links that the app should open.

In addition to subscribing to `CordialSwiftUIDeepLinksPublisher`, SwiftUI app should let the SDK know that a deep link is being opened from outside of the app. To let the SDK know that a deep link is being opened, in your `onOpenURL` methods, pass the deep link to `CordialSwiftUIDeepLinksHandler.processDeepLink` method. The SDK will then track the link, meaning it will send required system events as well as follow possible redirects that a deep link might contain, and will publish the resultant deep url link via `CordialSwiftUIDeepLinksPublisher`. 

For example, here is a typical view definition that is capable of opening deep links:

```
AppliationView()
    .onOpenURL { url in
        CordialSwiftUIDeepLinksHandler().processDeepLink(url: url)
    }.onReceive(self.deepLinksPublisher.deepLinks) { deepLinks in
    	// deepLinkURL is the @State variable that will trigger view refresh
        self.deepLinkURL = deepLinks.url
    }
```

Opening unknown deep links:

```
AppliationView()
    .onOpenURL { url in
        CordialSwiftUIDeepLinksHandler().processDeepLink(url: url)
    }.onReceive(self.deepLinksPublisher.deepLinks) { deepLinks in
        deepLinks.completionHandler(.OPEN_IN_BROWSER)
    }
```

## Additional publishers

In addition to `CordialSwiftUIDeepLinksPublisher`, the SDK contains these additional publishers:

- `CordialSwiftUIInAppMessagePublisher` - notifies the app of the inputs that were captured in an in-app message
- `CordialSwiftUIInboxMessagePublisher` - notifies the app of new inbox messages
- `CordialSwiftUIPushNotificationPublisher` - notifies the app that a new push notification token is received, push notification delivered when an app is on the foreground and app opened via push notification tap

[Top](#contents)
