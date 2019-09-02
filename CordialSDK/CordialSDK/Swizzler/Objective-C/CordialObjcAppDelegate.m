//
//  CordialObjcAppDelegate.m
//  CordialSDK
//
//  Created by Yan Malinovsky on 9/2/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

#import "CordialObjcAppDelegate.h"

@interface CordialObjcAppDelegate ()
    
@end

@implementation CordialObjcAppDelegate
    
// MARK: - Handle remote notification registration.

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
}

// MARK: Handle universal links

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    return NO;
}

// MARK: Handle URL schemes

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return NO;
}

// MARK: Handle background URLSession.

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    
}

@end
