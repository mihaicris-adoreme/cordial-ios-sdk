//
//  CordialContinueRestorationHandler.m
//  CordialDemo_Objective-C
//
//  Created by Yan Malinovsky on 7/29/19.
//

#import "CordialContinueRestorationHandler.h"

@implementation CordialContinueRestorationHandler

- (BOOL)appOpenViaUniversalLink:(UIApplication * _Nonnull)application continue:(NSUserActivity * _Nonnull)userActivity restorationHandler:(void (^ _Nonnull)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    return NO;
}

@end
