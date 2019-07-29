//
//  ViewController.m
//  CordialDemo_Objective-C
//
//  Created by Yan Malinovsky on 7/29/19.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setContact];
    [self sendBrowseCategoryCustomEvent];
}

- (void)setContact {
    CordialAPI *cordialAPI = [[CordialAPI alloc] init];
    
    NSString *email = @"yan.malinovsky@gmail.com";
    [cordialAPI setContactWithPrimaryKey:email];
}

- (void)sendBrowseCategoryCustomEvent {
    CordialAPI *cordialAPI = [[CordialAPI alloc] init];
    
    NSString *eventName = @"browse_category";
    
    id objects[] = { @"Mens" };
    id keys[] = { @"catalogName" };
    NSUInteger count = sizeof(objects) / sizeof(id);
    NSDictionary *properties = [NSDictionary dictionaryWithObjects:objects forKeys:keys count:count];
    
    SendCustomEventRequest *sendCustomEventRequest = [[SendCustomEventRequest alloc] initWithEventName:eventName properties:properties];
    [cordialAPI sendCustomEventWithSendCustomEventRequest:sendCustomEventRequest];
}

@end
