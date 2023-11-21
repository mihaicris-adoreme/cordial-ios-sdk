//
//  CordialDeepLinksHandler.m
//  CordialDemo_Objective-C
//
//  Created by Yan Malinovsky on 11.10.2019.
//

#import "CordialDeepLinksHandler.h"

@implementation CordialDeepLinksHandler

- (void)openDeepLinkWithDeepLink:(CordialDeepLink * _Nonnull)deepLink fallbackURL:(NSURL * _Nullable)fallbackURL completionHandler:(void (^ _Nonnull)(enum CordialDeepLinkActionType))completionHandler {
    // ShowSystemAlert
}

- (void)openDeepLinkWithDeepLink:(CordialDeepLink * _Nonnull)deepLink fallbackURL:(NSURL * _Nullable)fallbackURL scene:(UIScene * _Nonnull)scene completionHandler:(void (^ _Nonnull)(enum CordialDeepLinkActionType))completionHandler  API_AVAILABLE(ios(13.0)){
    // ShowSystemAlert
}

@end
