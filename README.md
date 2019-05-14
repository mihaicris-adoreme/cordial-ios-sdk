# iOS Cordial SDK Documentation

## Installation

### Cocoapods

Make sure you have access to CordialSDK gitlab repo. We recommend adding your SSH key to Gitlab. After that specify CordialSDK in your Podfile:

```
pod 'CordialSDK', :git => 'git@gitlab.com:CordialExperiences/mobile/ios-sdk.git'
```

And after that run:

```
pod install
```

This will add the the latest version of CordialSDK to your project.

Additionally, in order to take advantage of iOS 10 notification attachments, you will need to create a notification service extension near your main application. In order to do that create "Notification Service Extension" target and add CordialAppExtensions to it:

```
target "<The name of the new Notification Service Extension target>" do  
    use_frameworks!
    pod 'CordialAppExtensions', :git => 'git@gitlab.com:CordialExperiences/mobile/ios-sdk.git'  
end
```

Delete the code that your IDE generated for you for the new extension and inherit it from `CordialNotificationServiceExtension`:  

```
import CordialAppExtensions  
  
class NotificationService: CordialNotificationServiceExtension {  
  
}
```

## Initialize SDK
In order to initialize the SDK, pass your account key to `CordialApiConfiguration.initWithAccountKey` method and call it from `AppDelegate.didFinishLaunchingWithOptions`:

`CordialApiConfiguration.shared.initWithAccountKey(accountKey: “your account key“)`

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

```
let cordialApi = CordialAPI()
```

## Send custom events
Besides internal events, the SDK allows to send custom events specific to each app. Those may be, for example, user logged in, discount applied or app preferences updated to name a few. To send custom event, use the `CordialApi.sendCustomEvent` method:

```
let request = SendCustomEventRequest(eventName: “{custom event name}”, properties: [“{property name}”: “{property value}”])  
cordialApi.sendCustomEvent(sendCustomEventRequest: request)
```

`properties` - is a dictionary of string keys and string values that can be attached to the event. Can be nil.

## Upsert a contact
Every app is assumed to be operating on behalf of a specific contact. Contact is a user of the client application. For example, if Amazon is a client, each user of the Amazon who logs in is a contact. Every contact must have a primary key. Naturally that when the app is installed, the is no contact associated with the app as the user might not have logged in yet. In this case identifying a contact is done via device id, which is a unique identifier of the iOS device the app is running on. Every piece of information (internal or custom events, updating a contact etc) that is passed by SDK to Cordial backend has a device id automatically associated with it. Later, when the user logs into the app and his primary key becomes known, the client application must pass that primary key to the backed as part of updating a contact request. When the backend receives a contact update with the primary key it associates the device id with the primary key of a contact. That association is crucial to make effective use of Cordial.
To update a contact, use the `CordialApi.upsertContact` method:

```
let request = UpsertContactRequest(primaryKey: email, attributes: nil)
cordialAPI.upsertContact(upsertContactRequest: request)
```

`attributes` - is a dictionary of string keys and strings values attributes that can be attached to a contact. Can be nil.

## Post an order
When an order is posted in client application, the app should notify Cordial about that. In order to post an order to Cordial, use the `CordialApi.sendOrder` method:

```
сordialAPI.sendContactOrder(order: order)
```

The `order` object specifies things like orderId, storeId, customerId, billing and shipping addresses. 

## Post a cart
When a user updates the cart, the app should notify the Cordial backed by calling the `CordialApi.upsertCart` method:

```
сordialAPI.upsertContactCart(cartItems: items)
```

`items` is an array of, well, cart items. Each items has items sku, quantity, price and other cart item specific attributes.

## Caching
Every request described above is cached in case of its failure. For example, if internet is down on the device and an event failed to be delivered to Cordial, the event would be cached by the SDK and its delivery would be retried once internet connection is up again.

## Push notifications
The application must use Cordial SDK to configure push notifications. Make sure you’re not using iOS specific methods to register for push notifications as Cordial SDK would do it automatically.  In order to handle push notification taps, the only thing to do is to provide Cordial SDK with an instance of the `CordialPushNotificationDelegate` protocol. Do so in `AppDelegate.didFinishLaunchingWithOptions`:

```
let pushNotificationHandler = YourImplementationOfTheProtocol()  
CordialApiConfiguration.shared.pushNotificationHandler = pushNotificationHandler
```

**[INSERT A SECTION ON PROVIDING PUSH NOTIFICATION CERTIFICATE TO CORDIAL BACKEND]**

## Seeing the results

**[INSERT A SECTION ON WHERE TO CHECK THE EVENTS THAT THE SDK PUBLISHES]**