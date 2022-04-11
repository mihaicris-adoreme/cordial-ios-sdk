// Generated by Apple Swift version 5.5.1 (swiftlang-1300.0.31.4 clang-1300.0.29.6)
#ifndef CORDIALSDK_SWIFT_H
#define CORDIALSDK_SWIFT_H
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <Foundation/Foundation.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus)
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if __has_attribute(noescape)
# define SWIFT_NOESCAPE __attribute__((noescape))
#else
# define SWIFT_NOESCAPE
#endif
#if __has_attribute(ns_consumed)
# define SWIFT_RELEASES_ARGUMENT __attribute__((ns_consumed))
#else
# define SWIFT_RELEASES_ARGUMENT
#endif
#if __has_attribute(warn_unused_result)
# define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
# define SWIFT_WARN_UNUSED_RESULT
#endif
#if __has_attribute(noreturn)
# define SWIFT_NORETURN __attribute__((noreturn))
#else
# define SWIFT_NORETURN
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif
#if !defined(SWIFT_RESILIENT_CLASS)
# if __has_attribute(objc_class_stub)
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME) __attribute__((objc_class_stub))
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_class_stub)) SWIFT_CLASS_NAMED(SWIFT_NAME)
# else
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME)
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) SWIFT_CLASS_NAMED(SWIFT_NAME)
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if defined(__has_attribute) && __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR(_extensibility) __attribute__((enum_extensibility(_extensibility)))
# else
#  define SWIFT_ENUM_ATTR(_extensibility)
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name, _extensibility) enum _name : _type _name; enum SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) SWIFT_ENUM(_type, _name, _extensibility)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_WEAK_IMPORT)
# define SWIFT_WEAK_IMPORT __attribute__((weak_import))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if __has_feature(attribute_diagnose_if_objc)
# define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
#else
# define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
#endif
#if !defined(IBSegueAction)
# define IBSegueAction
#endif
#if __has_feature(modules)
#if __has_warning("-Watimport-in-framework-header")
#pragma clang diagnostic ignored "-Watimport-in-framework-header"
#endif
@import CoreData;
@import CoreLocation;
@import Foundation;
@import ObjectiveC;
@import UIKit;
@import UserNotifications;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"

#if __has_attribute(external_source_symbol)
# pragma push_macro("any")
# undef any
# pragma clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in="CordialSDK",generated_declaration))), apply_to=any(function,enum,objc_interface,objc_category,objc_protocol))
# pragma pop_macro("any")
#endif

@class NSString;
@class NSCoder;

SWIFT_CLASS("_TtC10CordialSDK7Address")
@interface Address : NSObject <NSCoding>
- (nonnull instancetype)initWithName:(NSString * _Nonnull)name address:(NSString * _Nonnull)address city:(NSString * _Nonnull)city state:(NSString * _Nonnull)state postalCode:(NSString * _Nonnull)postalCode country:(NSString * _Nonnull)country OBJC_DESIGNATED_INITIALIZER;
- (void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


SWIFT_PROTOCOL("_TtP10CordialSDK14AttributeValue_")
@protocol AttributeValue
@end


SWIFT_CLASS("_TtC10CordialSDK10ArrayValue")
@interface ArrayValue : NSObject <AttributeValue>
- (nonnull instancetype)init:(NSArray<NSString *> * _Nonnull)value OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


@class NSNumber;

SWIFT_CLASS("_TtC10CordialSDK12BooleanValue")
@interface BooleanValue : NSObject <AttributeValue>
- (nonnull instancetype)init:(BOOL)value OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


@class NSDate;

SWIFT_CLASS("_TtC10CordialSDK8CartItem")
@interface CartItem : NSObject <NSCoding>
- (nonnull instancetype)initWithProductID:(NSString * _Nonnull)productID name:(NSString * _Nonnull)name sku:(NSString * _Nonnull)sku category:(NSString * _Nonnull)category url:(NSString * _Nullable)url itemDescription:(NSString * _Nullable)itemDescription qtyNumber:(NSNumber * _Nonnull)qtyNumber itemPriceNumber:(NSNumber * _Nullable)itemPriceNumber salePriceNumber:(NSNumber * _Nullable)salePriceNumber attr:(NSDictionary<NSString *, NSString *> * _Nullable)attr images:(NSArray<NSString *> * _Nullable)images properties:(NSDictionary<NSString *, id> * _Nullable)properties;
- (void)seTimestampWithDate:(NSDate * _Nonnull)date;
- (NSString * _Nonnull)getTimestamp SWIFT_WARN_UNUSED_RESULT;
- (void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

@class NSEntityDescription;
@class NSManagedObjectContext;

SWIFT_CLASS_NAMED("ContactCartRequest")
@interface ContactCartRequest : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end

@class NSData;

@interface ContactCartRequest (SWIFT_EXTENSION(CordialSDK))
@property (nonatomic, strong) NSData * _Nullable data;
@end


SWIFT_CLASS_NAMED("ContactLogout")
@interface ContactLogout : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface ContactLogout (SWIFT_EXTENSION(CordialSDK))
@property (nonatomic, strong) NSData * _Nullable data;
@end


SWIFT_CLASS_NAMED("ContactOrderRequest")
@interface ContactOrderRequest : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface ContactOrderRequest (SWIFT_EXTENSION(CordialSDK))
@property (nonatomic, strong) NSData * _Nullable data;
@end


SWIFT_CLASS_NAMED("ContactRequest")
@interface ContactRequest : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface ContactRequest (SWIFT_EXTENSION(CordialSDK))
@property (nonatomic, strong) NSData * _Nullable data;
@end


SWIFT_CLASS_NAMED("ContactTimestampsURL")
@interface ContactTimestampsURL : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end

@class NSURL;

@interface ContactTimestampsURL (SWIFT_EXTENSION(CordialSDK))
@property (nonatomic, copy) NSDate * _Nullable expireDate;
@property (nonatomic, copy) NSURL * _Nullable url;
@end

@class Order;

SWIFT_CLASS("_TtC10CordialSDK10CordialAPI")
@interface CordialAPI : NSObject
- (NSString * _Nonnull)getAccountKey SWIFT_WARN_UNUSED_RESULT;
- (NSString * _Nonnull)getChannelKey SWIFT_WARN_UNUSED_RESULT;
- (NSString * _Nonnull)getEventsStreamURL SWIFT_WARN_UNUSED_RESULT;
- (NSString * _Nonnull)getMessageHubURL SWIFT_WARN_UNUSED_RESULT;
- (NSString * _Nullable)getContactPrimaryKey SWIFT_WARN_UNUSED_RESULT;
- (void)showSystemAlertWithTitle:(NSString * _Nonnull)title message:(NSString * _Nullable)message;
- (void)openDeepLinkWithUrl:(NSURL * _Nonnull)url;
- (NSString * _Nullable)getCurrentMcID SWIFT_WARN_UNUSED_RESULT;
- (void)setCurrentMcIDWithMcID:(NSString * _Nonnull)mcID;
- (void)setContactWithPrimaryKey:(NSString * _Nullable)primaryKey;
- (void)unsetContact;
- (void)upsertContactWithAttributes:(NSDictionary<NSString *, id <AttributeValue>> * _Nullable)attributes;
- (void)sendCustomEventWithEventName:(NSString * _Nonnull)eventName properties:(NSDictionary<NSString *, id> * _Nullable)properties;
- (void)flushEvents;
- (void)upsertContactCartWithCartItems:(NSArray<CartItem *> * _Nonnull)cartItems;
- (void)sendContactOrderWithOrder:(Order * _Nonnull)order;
- (void)registerForPushNotificationsWithOptions:(UNAuthorizationOptions)options;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class CordialOSLogManager;
@protocol CordialDeepLinksDelegate;
@protocol CordialPushNotificationDelegate;
@protocol InAppMessageInputsDelegate;
@protocol InboxMessageDelegate;
enum CordialPushNotificationConfigurationType : NSInteger;
enum CordialDeepLinksConfigurationType : NSInteger;
enum CordialURLSessionConfigurationType : NSInteger;
enum InAppMessagesDeliveryConfigurationType : NSInteger;
@class InboxMessageCache;
@class InAppMessageDelayMode;

SWIFT_CLASS("_TtC10CordialSDK23CordialApiConfiguration")
@interface CordialApiConfiguration : NSObject
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly, strong) CordialApiConfiguration * _Nonnull shared;)
+ (CordialApiConfiguration * _Nonnull)shared SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@property (nonatomic, readonly, strong) CordialOSLogManager * _Nonnull osLogManager;
@property (nonatomic, strong) id <CordialDeepLinksDelegate> _Nullable cordialDeepLinksDelegate;
@property (nonatomic, strong) id <CordialPushNotificationDelegate> _Nullable pushNotificationDelegate;
@property (nonatomic, strong) id <InAppMessageInputsDelegate> _Nullable inAppMessageInputsDelegate;
@property (nonatomic, strong) id <InboxMessageDelegate> _Nullable inboxMessageDelegate;
@property (nonatomic) enum CordialPushNotificationConfigurationType pushesConfiguration;
@property (nonatomic) enum CordialDeepLinksConfigurationType deepLinksConfiguration;
@property (nonatomic) enum CordialURLSessionConfigurationType backgroundURLSessionConfiguration;
@property (nonatomic) enum InAppMessagesDeliveryConfigurationType inAppMessagesDeliveryConfiguration;
@property (nonatomic, readonly, strong) InboxMessageCache * _Nonnull inboxMessageCache;
@property (nonatomic) NSInteger qtyCachedEventQueue;
@property (nonatomic, copy) NSDictionary<NSString *, id> * _Nullable systemEventsProperties;
@property (nonatomic, copy) NSArray<NSString *> * _Nonnull vanityDomains;
@property (nonatomic) NSInteger eventsBulkSize;
@property (nonatomic) NSTimeInterval eventsBulkUploadInterval;
@property (nonatomic, readonly, strong) InAppMessageDelayMode * _Nonnull inAppMessageDelayMode;
- (void)initializeWithAccountKey:(NSString * _Nonnull)accountKey channelKey:(NSString * _Nonnull)channelKey eventsStreamURL:(NSString * _Nonnull)eventsStreamURL messageHubURL:(NSString * _Nonnull)messageHubURL;
- (void)initializeLocationManagerWithDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy distanceFilter:(CLLocationDistance)distanceFilter untilTraveled:(CLLocationDistance)untilTraveled timeout:(NSTimeInterval)timeout;
@end


SWIFT_CLASS("_TtC10CordialSDK20CordialDateFormatter")
@interface CordialDateFormatter : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (NSString * _Nonnull)getCurrentTimestamp SWIFT_WARN_UNUSED_RESULT;
- (NSDate * _Nullable)getDateFromTimestampWithTimestamp:(NSString * _Nonnull)timestamp SWIFT_WARN_UNUSED_RESULT;
- (NSString * _Nonnull)getTimestampFromDateWithDate:(NSDate * _Nonnull)date SWIFT_WARN_UNUSED_RESULT;
- (BOOL)isValidTimestampWithTimestamp:(NSString * _Nonnull)timestamp SWIFT_WARN_UNUSED_RESULT;
@end

typedef SWIFT_ENUM(NSInteger, CordialDeepLinkActionType, closed) {
  CordialDeepLinkActionTypeNO_ACTION = 0,
  CordialDeepLinkActionTypeOPEN_IN_BROWSER = 1,
};

@class NSUserActivity;
@class UIScene;

SWIFT_CLASS("_TtC10CordialSDK19CordialDeepLinksAPI")
@interface CordialDeepLinksAPI : NSObject
- (void)openAppDelegateUniversalLinkWithUserActivity:(NSUserActivity * _Nonnull)userActivity;
- (void)openSceneDelegateUniversalLinkWithScene:(UIScene * _Nonnull)scene userActivity:(NSUserActivity * _Nonnull)userActivity SWIFT_AVAILABILITY(ios,introduced=13.0);
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class UIOpenURLContext;

SWIFT_CLASS("_TtC10CordialSDK36CordialDeepLinksConfigurationHandler")
@interface CordialDeepLinksConfigurationHandler : NSObject
- (BOOL)processAppContinueRestorationHandlerWithUserActivity:(NSUserActivity * _Nonnull)userActivity SWIFT_WARN_UNUSED_RESULT;
- (BOOL)processAppOpenOptionsWithUrl:(NSURL * _Nonnull)url SWIFT_WARN_UNUSED_RESULT;
- (void)processSceneContinueWithUserActivity:(NSUserActivity * _Nonnull)userActivity scene:(UIScene * _Nonnull)scene SWIFT_AVAILABILITY(ios,introduced=13.0);
- (void)processSceneOpenURLContextsWithURLContexts:(NSSet<UIOpenURLContext *> * _Nonnull)URLContexts scene:(UIScene * _Nonnull)scene SWIFT_AVAILABILITY(ios,introduced=13.0);
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

typedef SWIFT_ENUM(NSInteger, CordialDeepLinksConfigurationType, closed) {
  CordialDeepLinksConfigurationTypeSDK = 0,
  CordialDeepLinksConfigurationTypeAPP = 1,
};


SWIFT_PROTOCOL("_TtP10CordialSDK24CordialDeepLinksDelegate_")
@protocol CordialDeepLinksDelegate
- (void)openDeepLinkWithUrl:(NSURL * _Nonnull)url fallbackURL:(NSURL * _Nullable)fallbackURL completionHandler:(void (^ _Nonnull)(enum CordialDeepLinkActionType))completionHandler;
- (void)openDeepLinkWithUrl:(NSURL * _Nonnull)url fallbackURL:(NSURL * _Nullable)fallbackURL scene:(UIScene * _Nonnull)scene completionHandler:(void (^ _Nonnull)(enum CordialDeepLinkActionType))completionHandler SWIFT_AVAILABILITY(ios,introduced=13.0);
@end

@class PageRequest;
@class InboxFilter;
@class InboxPage;
@class InboxMessage;

SWIFT_CLASS("_TtC10CordialSDK22CordialInboxMessageAPI")
@interface CordialInboxMessageAPI : NSObject
- (void)sendInboxMessageReadEventWithMcID:(NSString * _Nonnull)mcID;
- (void)fetchInboxMessagesWithPageRequest:(PageRequest * _Nonnull)pageRequest inboxFilter:(InboxFilter * _Nullable)inboxFilter onSuccess:(void (^ _Nonnull)(InboxPage * _Nonnull))onSuccess onFailure:(void (^ _Nonnull)(NSString * _Nonnull))onFailure;
- (void)markInboxMessagesReadWithMcIDs:(NSArray<NSString *> * _Nonnull)mcIDs;
- (void)markInboxMessagesUnreadWithMcIDs:(NSArray<NSString *> * _Nonnull)mcIDs;
- (void)fetchInboxMessageWithMcID:(NSString * _Nonnull)mcID onSuccess:(void (^ _Nonnull)(InboxMessage * _Nonnull))onSuccess onFailure:(void (^ _Nonnull)(NSString * _Nonnull))onFailure;
- (void)fetchInboxMessageContentWithMcID:(NSString * _Nonnull)mcID onSuccess:(void (^ _Nonnull)(NSString * _Nonnull))onSuccess onFailure:(void (^ _Nonnull)(NSString * _Nonnull))onFailure;
- (void)deleteInboxMessageWithMcID:(NSString * _Nonnull)mcID;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

enum logLevel : NSInteger;

SWIFT_CLASS("_TtC10CordialSDK19CordialOSLogManager")
@interface CordialOSLogManager : NSObject
- (void)setLogLevel:(enum logLevel)logLevel;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

typedef SWIFT_ENUM(NSInteger, CordialPushNotificationConfigurationType, closed) {
  CordialPushNotificationConfigurationTypeSDK = 0,
  CordialPushNotificationConfigurationTypeAPP = 1,
};


SWIFT_PROTOCOL("_TtP10CordialSDK31CordialPushNotificationDelegate_")
@protocol CordialPushNotificationDelegate
- (void)appOpenViaNotificationTapWithNotificationContent:(NSDictionary * _Nonnull)notificationContent;
- (void)notificationDeliveredInForegroundWithNotificationContent:(NSDictionary * _Nonnull)notificationContent;
- (void)apnsTokenReceivedWithToken:(NSString * _Nonnull)token;
@end


SWIFT_CLASS("_TtC10CordialSDK30CordialPushNotificationHandler")
@interface CordialPushNotificationHandler : NSObject
- (BOOL)isCordialMessageWithUserInfo:(NSDictionary * _Nonnull)userInfo SWIFT_WARN_UNUSED_RESULT;
- (void)processNewPushNotificationTokenWithDeviceToken:(NSData * _Nonnull)deviceToken;
- (void)processAppOpenViaPushNotificationTapWithUserInfo:(NSDictionary * _Nonnull)userInfo completionHandler:(SWIFT_NOESCAPE void (^ _Nonnull)(void))completionHandler;
- (void)processNotificationDeliveryInForegroundWithUserInfo:(NSDictionary * _Nonnull)userInfo completionHandler:(SWIFT_NOESCAPE void (^ _Nonnull)(UNNotificationPresentationOptions))completionHandler;
- (void)processSilentPushDeliveryWithUserInfo:(NSDictionary * _Nonnull)userInfo;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC10CordialSDK37CordialURLSessionConfigurationHandler")
@interface CordialURLSessionConfigurationHandler : NSObject
- (BOOL)isCordialURLSessionWithIdentifier:(NSString * _Nonnull)identifier SWIFT_WARN_UNUSED_RESULT;
- (void)processURLSessionCompletionHandlerWithIdentifier:(NSString * _Nonnull)identifier completionHandler:(void (^ _Nonnull)(void))completionHandler;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

typedef SWIFT_ENUM(NSInteger, CordialURLSessionConfigurationType, closed) {
  CordialURLSessionConfigurationTypeSDK = 0,
  CordialURLSessionConfigurationTypeAPP = 1,
};


SWIFT_CLASS_NAMED("CustomEventRequest")
@interface CustomEventRequest : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface CustomEventRequest (SWIFT_EXTENSION(CordialSDK))
@property (nonatomic, copy) NSData * _Nullable data;
@property (nonatomic, copy) NSString * _Nullable requestID;
@end


SWIFT_CLASS("_TtC10CordialSDK9DateValue")
@interface DateValue : NSObject <AttributeValue>
- (nonnull instancetype)init:(NSDate * _Nonnull)value OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


SWIFT_CLASS("_TtC10CordialSDK23DependencyConfiguration")
@interface DependencyConfiguration : NSObject
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly, strong) DependencyConfiguration * _Nonnull shared;)
+ (DependencyConfiguration * _Nonnull)shared SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
- (NSString * _Nonnull)getCustomEventJSONWithEventName:(NSString * _Nonnull)eventName properties:(NSDictionary<NSString *, NSString *> * _Nullable)properties SWIFT_WARN_UNUSED_RESULT;
@end


SWIFT_CLASS("_TtC10CordialSDK8GeoValue")
@interface GeoValue : NSObject <AttributeValue>
- (void)setCity:(NSString * _Nonnull)city;
- (void)setCountry:(NSString * _Nonnull)country;
- (void)setPostalCode:(NSString * _Nonnull)postalCode;
- (void)setState:(NSString * _Nonnull)state;
- (void)setStreetAddress:(NSString * _Nonnull)streetAddress;
- (void)setStreetAddress2:(NSString * _Nonnull)streetAddress2;
- (void)setTimeZone:(NSString * _Nonnull)timeZone;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS_NAMED("InAppMessageContentURL")
@interface InAppMessageContentURL : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface InAppMessageContentURL (SWIFT_EXTENSION(CordialSDK))
@property (nonatomic, copy) NSDate * _Nullable expireDate;
@property (nonatomic, copy) NSString * _Nullable mcID;
@property (nonatomic, copy) NSURL * _Nullable url;
@end


SWIFT_CLASS("_TtC10CordialSDK21InAppMessageDelayMode")
@interface InAppMessageDelayMode : NSObject
- (void)show;
- (void)delayedShow;
- (void)disallowedControllers:(NSArray<Class> * _Nonnull)disallowedControllersType;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class NSBundle;

SWIFT_CLASS("_TtC10CordialSDK31InAppMessageDelayViewController")
@interface InAppMessageDelayViewController : UIViewController
- (void)viewDidDisappear:(BOOL)animated;
- (nonnull instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)coder OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_PROTOCOL("_TtP10CordialSDK26InAppMessageInputsDelegate_")
@protocol InAppMessageInputsDelegate
- (void)inputsCapturedWithEventName:(NSString * _Nonnull)eventName properties:(NSDictionary<NSString *, id> * _Nonnull)properties;
@end


SWIFT_CLASS_NAMED("InAppMessagesCache")
@interface InAppMessagesCache : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface InAppMessagesCache (SWIFT_EXTENSION(CordialSDK))
@property (nonatomic, copy) NSData * _Nullable data;
@property (nonatomic, copy) NSDate * _Nullable date;
@property (nonatomic, copy) NSString * _Nullable displayType;
@property (nonatomic, copy) NSString * _Nullable mcID;
@end

typedef SWIFT_ENUM(NSInteger, InAppMessagesDeliveryConfigurationType, closed) {
  InAppMessagesDeliveryConfigurationTypeSilentPushes = 0,
  InAppMessagesDeliveryConfigurationTypeDirectDelivery = 1,
};


SWIFT_CLASS_NAMED("InAppMessagesParam")
@interface InAppMessagesParam : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface InAppMessagesParam (SWIFT_EXTENSION(CordialSDK))
@property (nonatomic) int16_t bottom;
@property (nonatomic, copy) NSDate * _Nullable date;
@property (nonatomic, copy) NSString * _Nullable displayType;
@property (nonatomic, copy) NSDate * _Nullable expirationTime;
@property (nonatomic, copy) NSString * _Nullable inactiveSessionDisplay;
@property (nonatomic) int16_t left;
@property (nonatomic, copy) NSString * _Nullable mcID;
@property (nonatomic) int16_t right;
@property (nonatomic) int16_t top;
@property (nonatomic, copy) NSString * _Nullable type;
@end


SWIFT_CLASS_NAMED("InAppMessagesQueue")
@interface InAppMessagesQueue : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface InAppMessagesQueue (SWIFT_EXTENSION(CordialSDK))
@property (nonatomic, strong) NSDate * _Nullable date;
@property (nonatomic, copy) NSString * _Nullable mcID;
@end


SWIFT_CLASS_NAMED("InAppMessagesRelated")
@interface InAppMessagesRelated : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface InAppMessagesRelated (SWIFT_EXTENSION(CordialSDK))
@property (nonatomic, copy) NSString * _Nullable mcID;
@end


SWIFT_CLASS_NAMED("InAppMessagesShown")
@interface InAppMessagesShown : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface InAppMessagesShown (SWIFT_EXTENSION(CordialSDK))
@property (nonatomic, copy) NSString * _Nullable mcID;
@end

enum InboxFilterIsReadType : NSInteger;

SWIFT_CLASS("_TtC10CordialSDK11InboxFilter")
@interface InboxFilter : NSObject
@property (nonatomic) enum InboxFilterIsReadType isRead;
@property (nonatomic, copy) NSDate * _Nullable fromDate;
@property (nonatomic, copy) NSDate * _Nullable toDate;
- (nonnull instancetype)initWithIsRead:(enum InboxFilterIsReadType)isRead fromDate:(NSDate * _Nullable)fromDate toDate:(NSDate * _Nullable)toDate OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

typedef SWIFT_ENUM(NSInteger, InboxFilterIsReadType, closed) {
  InboxFilterIsReadTypeNone = 0,
  InboxFilterIsReadTypeYes = 1,
  InboxFilterIsReadTypeNo = 2,
};


SWIFT_CLASS("_TtC10CordialSDK12InboxMessage")
@interface InboxMessage : NSObject <NSCoding>
@property (nonatomic, readonly, copy) NSString * _Nonnull mcID;
@property (nonatomic, readonly) BOOL isRead;
@property (nonatomic, readonly, copy) NSDate * _Nonnull sentAt;
@property (nonatomic, readonly, copy) NSString * _Nullable metadata;
- (void)encodeWithCoder:(NSCoder * _Nonnull)coder;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)coder;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


SWIFT_CLASS("_TtC10CordialSDK17InboxMessageCache")
@interface InboxMessageCache : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@property (nonatomic) NSInteger maxCacheSize;
@property (nonatomic) NSInteger maxCachableMessageSize;
@end


SWIFT_PROTOCOL("_TtP10CordialSDK20InboxMessageDelegate_")
@protocol InboxMessageDelegate
- (void)newInboxMessageDeliveredWithMcID:(NSString * _Nonnull)mcID;
@end


SWIFT_CLASS_NAMED("InboxMessageDeleteRequests")
@interface InboxMessageDeleteRequests : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface InboxMessageDeleteRequests (SWIFT_EXTENSION(CordialSDK))
@property (nonatomic, copy) NSData * _Nullable data;
@end


SWIFT_CLASS_NAMED("InboxMessagesCache")
@interface InboxMessagesCache : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface InboxMessagesCache (SWIFT_EXTENSION(CordialSDK))
@property (nonatomic, copy) NSData * _Nullable data;
@property (nonatomic, copy) NSString * _Nullable mcID;
@end


SWIFT_CLASS_NAMED("InboxMessagesContent")
@interface InboxMessagesContent : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface InboxMessagesContent (SWIFT_EXTENSION(CordialSDK))
@property (nonatomic, copy) NSString * _Nullable content;
@property (nonatomic, copy) NSString * _Nullable mcID;
@property (nonatomic) int64_t size;
@end


SWIFT_CLASS_NAMED("InboxMessagesReadUnreadMarks")
@interface InboxMessagesReadUnreadMarks : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface InboxMessagesReadUnreadMarks (SWIFT_EXTENSION(CordialSDK))
@property (nonatomic, copy) NSData * _Nullable data;
@property (nonatomic, copy) NSDate * _Nullable date;
@end


SWIFT_CLASS("_TtC10CordialSDK9InboxPage")
@interface InboxPage : NSObject
@property (nonatomic, readonly, copy) NSArray<InboxMessage *> * _Nonnull content;
@property (nonatomic, readonly) NSInteger total;
@property (nonatomic, readonly) NSInteger size;
@property (nonatomic, readonly) NSInteger current;
@property (nonatomic, readonly) NSInteger last;
- (BOOL)hasNext SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end




@interface NSNotification (SWIFT_EXTENSION(CordialSDK))
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) NSNotificationName _Nonnull cordialConnectedToInternet;)
+ (NSNotificationName _Nonnull)cordialConnectedToInternet SWIFT_WARN_UNUSED_RESULT;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) NSNotificationName _Nonnull cordialNotConnectedToInternet;)
+ (NSNotificationName _Nonnull)cordialNotConnectedToInternet SWIFT_WARN_UNUSED_RESULT;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) NSNotificationName _Nonnull cordialSendCustomEventsLogicError;)
+ (NSNotificationName _Nonnull)cordialSendCustomEventsLogicError SWIFT_WARN_UNUSED_RESULT;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) NSNotificationName _Nonnull cordialUpsertContactCartLogicError;)
+ (NSNotificationName _Nonnull)cordialUpsertContactCartLogicError SWIFT_WARN_UNUSED_RESULT;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) NSNotificationName _Nonnull cordialSendContactOrdersLogicError;)
+ (NSNotificationName _Nonnull)cordialSendContactOrdersLogicError SWIFT_WARN_UNUSED_RESULT;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) NSNotificationName _Nonnull cordialUpsertContactsLogicError;)
+ (NSNotificationName _Nonnull)cordialUpsertContactsLogicError SWIFT_WARN_UNUSED_RESULT;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) NSNotificationName _Nonnull cordialSendContactLogoutLogicError;)
+ (NSNotificationName _Nonnull)cordialSendContactLogoutLogicError SWIFT_WARN_UNUSED_RESULT;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) NSNotificationName _Nonnull cordialInAppMessageLogicError;)
+ (NSNotificationName _Nonnull)cordialInAppMessageLogicError SWIFT_WARN_UNUSED_RESULT;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) NSNotificationName _Nonnull cordialInboxMessagesMarkReadUnreadLogicError;)
+ (NSNotificationName _Nonnull)cordialInboxMessagesMarkReadUnreadLogicError SWIFT_WARN_UNUSED_RESULT;
@end




SWIFT_CLASS("_TtC10CordialSDK12NumericValue")
@interface NumericValue : NSObject <AttributeValue>
- (nonnull instancetype)initWithDoubleValue:(double)doubleValue OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithIntValue:(NSInteger)intValue OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end



SWIFT_CLASS("_TtC10CordialSDK5Order")
@interface Order : NSObject <NSCoding>
- (nonnull instancetype)initWithOrderID:(NSString * _Nonnull)orderID status:(NSString * _Nonnull)status storeID:(NSString * _Nonnull)storeID customerID:(NSString * _Nonnull)customerID shippingAddress:(Address * _Nonnull)shippingAddress billingAddress:(Address * _Nonnull)billingAddress items:(NSArray<CartItem *> * _Nonnull)items taxNumber:(NSNumber * _Nullable)taxNumber shippingAndHandling:(NSNumber * _Nullable)shippingAndHandling properties:(NSDictionary<NSString *, id> * _Nullable)properties;
- (void)setPurchaseDateWithDate:(NSDate * _Nonnull)date;
- (NSString * _Nonnull)getPurchaseDate SWIFT_WARN_UNUSED_RESULT;
- (void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


SWIFT_CLASS("_TtC10CordialSDK11PageRequest")
@interface PageRequest : NSObject
- (nonnull instancetype)initWithPage:(NSInteger)page size:(NSInteger)size OBJC_DESIGNATED_INITIALIZER;
- (PageRequest * _Nonnull)next SWIFT_WARN_UNUSED_RESULT;
- (PageRequest * _Nonnull)previous SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


SWIFT_CLASS("_TtC10CordialSDK13RequestSender")
@interface RequestSender : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC10CordialSDK13ResponseError")
@interface ResponseError : NSObject
@property (nonatomic, readonly, copy) NSString * _Nonnull message;
@property (nonatomic, readonly, copy) NSString * _Nullable responseBody;
@property (nonatomic, readonly) NSError * _Nullable systemError;
- (nonnull instancetype)initWithMessage:(NSString * _Nonnull)message statusCodeNumber:(NSNumber * _Nullable)statusCodeNumber responseBody:(NSString * _Nullable)responseBody systemError:(NSError * _Nullable)systemError;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


SWIFT_CLASS("_TtC10CordialSDK11StringValue")
@interface StringValue : NSObject <AttributeValue>
- (nonnull instancetype)init:(NSString * _Nonnull)value OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end



typedef SWIFT_ENUM(NSInteger, logLevel, closed) {
  logLevelNone = 0,
  logLevelAll = 1,
  logLevelError = 2,
  logLevelInfo = 3,
};

#if __has_attribute(external_source_symbol)
# pragma clang attribute pop
#endif
#pragma clang diagnostic pop
#endif
