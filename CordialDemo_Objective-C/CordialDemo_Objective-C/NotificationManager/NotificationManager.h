//
//  NotificationManager.h
//  CordialDemo_Objective-C
//
//  Created by Yan Malinovsky on 9/11/19.
//

#import <UIKit/UIKit.h>
#import <CordialSDK/CordialSDK-Swift.h>

@interface NotificationManager : NSObject
+ shared;
- (void)setupCordialSDKLogicErrorHandler;
@end

