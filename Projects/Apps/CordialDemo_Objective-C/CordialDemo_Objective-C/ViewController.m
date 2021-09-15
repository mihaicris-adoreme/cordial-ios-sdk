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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self upsertContact];
        [self sendBrowseCategoryCustomEvent];
        [self upsertContactCart];
        [self sendContactOrder];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendContactLogout];
        });
    });
}

- (void)setContact {
    CordialAPI *cordialAPI = [[CordialAPI alloc] init];
    
    NSString *primaryKey = @"TEST_PRIMARY_KEY";
    [cordialAPI setContactWithPrimaryKey:primaryKey];
}

- (void)upsertContact {
    CordialAPI *cordialAPI = [[CordialAPI alloc] init];

    StringValue *name = [[StringValue alloc] init:@"Jon Doe"];
    BooleanValue *employed = [[BooleanValue alloc] init:TRUE];
    NumericValue *age = [[NumericValue alloc] initWithIntValue:32];
    ArrayValue *children = [[ArrayValue alloc] init:@[@"Sofia", @"Jack"]];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:name forKey:@"name"];
    [attributes setObject:employed forKey:@"employed"];
    [attributes setObject:age forKey:@"age"];
    [attributes setObject:children forKey:@"children"];
    
    [cordialAPI upsertContactWithAttributes:attributes];
}

- (void)sendBrowseCategoryCustomEvent {
    CordialAPI *cordialAPI = [[CordialAPI alloc] init];
    
    NSString *eventName = @"browse_category";
    
    NSDictionary *properties = @{ @"catalogName" :@"Mens" };
    
    [cordialAPI sendCustomEventWithEventName:eventName properties:properties];
}

- (void)upsertContactCart {
    CordialAPI *cordialAPI = [[CordialAPI alloc] init];
    [cordialAPI upsertContactCartWithCartItems:[self getCartItems]];
}

- (NSArray<CartItem *>*)getCartItems {
    NSNumber *qty = [NSNumber numberWithInteger:1];
    NSNumber *price = [NSNumber numberWithDouble:148.00];
    CartItem *cartItem = [[CartItem alloc] initWithProductID:@"1" name:@"men1" sku:@"ab26ec3a-6110-11e9-8647-d663bd873d93" category:@"Mens" url:nil itemDescription:nil qtyNumber:qty itemPriceNumber:price salePriceNumber:price attr:nil images:nil properties:nil];
    
    NSArray *cartItems = [[NSArray alloc] initWithObjects:cartItem, nil];
    
    return cartItems;
}

- (void)sendContactOrder {
    CordialAPI *cordialAPI = [[CordialAPI alloc] init];
    
    Address *shippingAddress = [[Address alloc] initWithName:@"shippingAddressName" address:@"shippingAddress" city:@"shippingAddressCity" state:@"shippingAddressState" postalCode:@"shippingAddressPostalCode" country:@"shippingAddressCountry"];
    Address *billingAddress = [[Address alloc] initWithName:@"billingAddressName" address:@"billingAddress" city:@"billingAddressCity" state:@"billingAddressState" postalCode:@"billingAddressPostalCode" country:@"billingAddressCountry"];
    
    NSString *orderID = [[NSUUID alloc] init].UUIDString;
    
    Order *order = [[Order alloc] initWithOrderID:orderID status:@"orderStatus" storeID:@"storeID" customerID:@"customerID" shippingAddress:shippingAddress billingAddress:billingAddress items:[self getCartItems] taxNumber:nil shippingAndHandling:nil properties:nil];
    
    [cordialAPI sendContactOrderWithOrder:order];
}

- (void)sendContactLogout {
    CordialAPI *cordialAPI = [[CordialAPI alloc] init];
    [cordialAPI unsetContact];
}

@end
