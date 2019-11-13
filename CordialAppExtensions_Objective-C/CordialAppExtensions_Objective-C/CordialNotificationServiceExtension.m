//
//  CordialNotificationServiceExtension.m
//  CordialAppExtensions_Objective-C
//
//  Created by Yan Malinovsky on 7/30/19.
//

#import "CordialNotificationServiceExtension.h"

@interface CordialNotificationServiceExtension ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation CordialNotificationServiceExtension

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    
    // Start
    
    NSString *urlString = request.content.userInfo[@"imageURL"];
    
    if (urlString == nil) {
        self.contentHandler(self.bestAttemptContent);
    }
    
    NSURL *fileUrl = [[NSURL alloc] initWithString:urlString];
    
    if (fileUrl == nil) {
        self.contentHandler(self.bestAttemptContent);
    }
    
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:fileUrl];
    
    if (imageData == nil) {
        self.contentHandler(self.bestAttemptContent);
    }
    
    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:NSProcessInfo.processInfo.globallyUniqueString];
    NSURL *folderURL = [[NSURL alloc] initFileURLWithPath:filePath];
    
    @try {
        NSError *error = nil;
        NSString *fileIdentifier = @"image";
        [fileManager createDirectoryAtURL:folderURL withIntermediateDirectories:YES attributes:nil error:&error];
        NSURL *fileURL = [folderURL URLByAppendingPathComponent:fileIdentifier];
        [imageData writeToURL:fileURL options:NSDataWritingAtomic error:&error];
        UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:fileIdentifier URL:fileURL options:nil error:&error];
        self.bestAttemptContent.attachments = [NSArray arrayWithObject:attachment];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    } @finally {
        NSLog(@"Finally condition");
    }
    
    // End
    
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
