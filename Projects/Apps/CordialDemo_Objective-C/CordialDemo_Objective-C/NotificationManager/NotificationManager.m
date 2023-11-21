//
//  NotificationManager.m
//  CordialDemo_Objective-C
//
//  Created by Yan Malinovsky on 9/11/19.
//

#import "NotificationManager.h"

@interface NotificationManager()
    
@end

@implementation NotificationManager
    
static NotificationManager *singletonObject = nil;
    
+ (id) shared {
    if (!singletonObject) {
        singletonObject = [[NotificationManager alloc] init];
    }
    
    return singletonObject;
}
    
- (id)init {
    if (!singletonObject) {
        singletonObject = [super init];
        // Uncomment the following line to see how many times is the init method of the class is called
        // NSLog(@"%s", __PRETTY_FUNCTION__);
    }
    
    return singletonObject;
}

- (void)setupCordialSDKLogicErrorHandler {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self name:NSNotification.cordialSendCustomEventsLogicError object:nil];
    [notificationCenter addObserver:self selector:@selector(cordialNotificationErrorHandler:) name:NSNotification.cordialSendCustomEventsLogicError object:nil];
    
    [notificationCenter removeObserver:self name:NSNotification.cordialUpsertContactCartLogicError object:nil];
    [notificationCenter addObserver:self selector:@selector(cordialNotificationErrorHandler:) name:NSNotification.cordialUpsertContactCartLogicError object:nil];
    
    [notificationCenter removeObserver:self name:NSNotification.cordialSendContactOrdersLogicError object:nil];
    [notificationCenter addObserver:self selector:@selector(cordialNotificationErrorHandler:) name:NSNotification.cordialSendContactOrdersLogicError object:nil];
    
    [notificationCenter removeObserver:self name:NSNotification.cordialUpsertContactsLogicError object:nil];
    [notificationCenter addObserver:self selector:@selector(cordialNotificationErrorHandler:) name:NSNotification.cordialUpsertContactsLogicError object:nil];
    
    [notificationCenter removeObserver:self name:NSNotification.cordialSendContactLogoutLogicError object:nil];
    [notificationCenter addObserver:self selector:@selector(cordialNotificationErrorHandler:) name:NSNotification.cordialSendContactLogoutLogicError object:nil];

    [notificationCenter removeObserver:self name:NSNotification.cordialInAppMessageLogicError object:nil];
    [notificationCenter addObserver:self selector:@selector(cordialNotificationErrorHandler:) name:NSNotification.cordialInAppMessageLogicError object:nil];
}

- (void)cordialNotificationErrorHandler:(NSNotification*)notification {
    if ([notification.object isKindOfClass:[ResponseError class]]) {
        ResponseError *responseError = notification.object;
        // ShowSystemAlert
    }
}
    
@end
