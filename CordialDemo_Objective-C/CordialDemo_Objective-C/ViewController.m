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
    [self upsertContactCart];
    [self sendContactOrder];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self sendContactLogout];
    });
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

- (void)upsertContactCart {
    CordialAPI *cordialAPI = [[CordialAPI alloc] init];
    [cordialAPI upsertContactCartWithCartItems:[self getCartItems]];
}

- (NSArray<CartItem *>*)getCartItems {
    NSNumber *qty = [NSNumber numberWithInteger:1];
    NSNumber *price = [NSNumber numberWithDouble:148.00];
    CartItem *cartItem = [[CartItem alloc] initWithProductID:@"1" name:@"men1" sku:@"ab26ec3a-6110-11e9-8647-d663bd873d93" category:nil url:nil itemDescription:nil qtyNumber:qty itemPriceNumber:price salePriceNumber:price attr:nil images:nil properties:nil];
    
    NSArray *cartItems = [[NSArray alloc] initWithObjects:cartItem, nil];
    
    return cartItems;
}

- (void)sendContactOrder {
    CordialAPI *cordialAPI = [[CordialAPI alloc] init];
    
    Address *shippingAddress = [[Address alloc] initWithName:@"shippingAddressName" address:@"shippingAddress" city:@"shippingAddressCity" state:@"shippingAddressState" postalCode:@"shippingAddressPostalCode" country:@"shippingAddressCountry"];
    Address *billingAddress = [[Address alloc] initWithName:@"billingAddressName" address:@"billingAddress" city:@"billingAddressCity" state:@"billingAddressState" postalCode:@"billingAddressPostalCode" country:@"billingAddressCountry"];
    
    NSString *orderID = [[NSUUID alloc] init].UUIDString;

    NSDate *purchaseDate = [[NSDate alloc] init];
    
    Order *order = [[Order alloc] initWithOrderID:orderID status:@"orderStatus" storeID:@"storeID" customerID:@"customerID" purchaseDate:purchaseDate shippingAddress:shippingAddress billingAddress:billingAddress items:[self getCartItems] taxNumber:nil shippingAndHandling:nil properties:nil];
    
    [cordialAPI sendContactOrderWithOrder:order];
}

- (void)sendContactLogout {
    CordialAPI *cordialAPI = [[CordialAPI alloc] init];
    [cordialAPI unsetContact];
}

@end
