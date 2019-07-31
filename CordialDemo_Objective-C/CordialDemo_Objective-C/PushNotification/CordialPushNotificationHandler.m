//
//  CordialPushNotificationHandler.m
//  CordialDemo_Objective-C
//
//  Created by Yan Malinovsky on 7/29/19.
//

#import "CordialPushNotificationHandler.h"

@implementation CordialPushNotificationHandler 

- (void)appOpenViaNotificationTapWithNotificationContent:(NSDictionary * _Nonnull)notificationContent completionHandler:(void (^ _Nonnull)(void))completionHandler {
    completionHandler();
}

- (void)notificationDeliveredInForegroundWithNotificationContent:(NSDictionary * _Nonnull)notificationContent completionHandler:(void (^ _Nonnull)(void))completionHandler {
    completionHandler();
}

@end
