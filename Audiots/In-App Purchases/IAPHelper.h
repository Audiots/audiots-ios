//
//  IAPHelper.h
//  Audiots
//
//  Created by Tan Bui on 4/28/16.
//  Copyright © 2016 Perfect Sense Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
UIKIT_EXTERN NSString *const IAPHelperProductRestoredNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;


- (void)provideContentForProductIdentifier:(NSString *)productIdentifier withTransactionState: (SKPaymentTransactionState) state;

-(void) reload;

@end
