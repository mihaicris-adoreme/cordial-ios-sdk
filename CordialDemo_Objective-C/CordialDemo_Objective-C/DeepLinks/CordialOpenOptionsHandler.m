//
//  CordialOpenOptionsHandler.m
//  CordialDemo_Objective-C
//
//  Created by Yan Malinovsky on 7/29/19.
//

#import "CordialOpenOptionsHandler.h"

@implementation CordialOpenOptionsHandler

- (BOOL)appOpenViaUrlScheme:(UIApplication * _Nonnull)app open:(NSURL * _Nonnull)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> * _Nonnull)options {
    return NO;
}

@end
