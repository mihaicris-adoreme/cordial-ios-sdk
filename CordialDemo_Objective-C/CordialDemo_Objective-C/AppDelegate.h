//
//  AppDelegate.h
//  CordialDemo_Objective-C
//
//  Created by Yan Malinovsky on 7/29/19.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import <CordialSDK/CordialSDK-Swift.h>
#import "CordialPushNotificationHandler.h"
#import "CordialContinueRestorationHandler.h"
#import "CordialOpenOptionsHandler.h"
#import "NotificationManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

@end

