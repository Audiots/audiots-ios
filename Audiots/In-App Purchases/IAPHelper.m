//
//  IAPHelper.m
//  Audiots
//
//  Created by Tan Bui on 4/28/16.
//  Copyright © 2016 Perfect Sense Digital. All rights reserved.
//

#import "IAPHelper.h"

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString *const IAPHelperProductRestoredNotification = @"IAPHelperProductRestoreNotification";

@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end

@implementation IAPHelper {
    
    //
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
    
    NSUserDefaults *_userDefault;
}

/**
 *  Set statusChanged bit
 *
 *  @return <#return value description#>
 */
-(BOOL) statusChanged{
    NSLog(@"Get statusChanged: %@", [_userDefault boolForKey:@"StatusChanged"] ? @"YES" : @"NO");
    return [_userDefault boolForKey:@"StatusChanged"];
}

/**
 *  Set the statusChanged bit when Purchase or Restore is made
 *
 *  @param status description
 */
-(void) setStatusChanged: (BOOL) status {
    NSLog(@"Set statusChanged: %@", status ? @"YES" : @"NO" );
    [_userDefault setBool:status forKey:@"StatusChanged"];
    [_userDefault synchronize];
}



- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        _userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.4-girls-tech.audiots"];
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        [self reload];

        // Add self as transaction observer
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    
    return self;
}


-(void) reload {
    
    // Check for previously purchased products
    _purchasedProductIdentifiers = [NSMutableSet set];
    
    // This will check to see which products have been purchased or not (based on the values saved in NSUserDefaults) and keep track of the product identifiers that have been purchased in a list.
    for (NSString * productIdentifier in _productIdentifiers) {
        
        BOOL productPurchased = [_userDefault boolForKey:productIdentifier];
        if (productPurchased) {
            [_purchasedProductIdentifiers addObject:productIdentifier];
            NSLog(@"Previously purchased: %@", productIdentifier);
        } else {
            NSLog(@"Not purchased: %@", productIdentifier); }
    }
    
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    // 1
    _completionHandler = [completionHandler copy];
    // 2
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    
    // SKProductsRequestDelegate - productsRequest(...)
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    //NSLog(@"Buying %@...", product.productIdentifier);
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    //NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: ID: \"%@\" Title: \"%@\" Pricing: $%0.2f", skProduct.productIdentifier, skProduct.localizedTitle, skProduct.price.floatValue);
    }
    
    if (_completionHandler != nil) {
        _completionHandler(YES, skProducts);
        _completionHandler = nil;
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    
    _productsRequest = nil;
    _completionHandler(NO, nil);
    _completionHandler = nil; }

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                
                if (transaction.downloads != nil && transaction.downloads.count > 0) {
                    
                    [[SKPaymentQueue defaultQueue] startDownloads:transaction.downloads];
                    
                } else {
                    [self completeTransaction:transaction];
                }
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
            break; }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier withTransactionState:transaction.transactionState];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier withTransactionState:transaction.transactionState];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray<SKDownload *> *)downloads {
    
    for (SKDownload *download in downloads) {
        
        switch (download.downloadState) {
            case SKDownloadStateActive:
                NSLog(@"Download progress: %f", download.progress);
                NSLog(@"Time remaining: %f", download.timeRemaining);
                break;
            case SKDownloadStateFinished:
                NSLog(@"Download is finished, content is available");
                NSLog(@"Content URL: %@", download.contentURL);
                break;
            case SKDownloadStateFailed:
                NSLog(@"Download Failed");
                break;
            case SKDownloadStateCancelled:
                NSLog(@"Download was cancelled");
                break;
            case SKDownloadStatePaused:
                NSLog(@"Download Paused");
                break;
            case SKDownloadStateWaiting:
                NSLog(@"Download is inactive, waiting to be downloaded");
                break;
            default:
                break;
        }
    }
    
}

// Add new method
- (void)provideContentForProductIdentifier:(NSString *)productIdentifier withTransactionState: (SKPaymentTransactionState) state {
    
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [_userDefault setBool:YES forKey:productIdentifier];
    [_userDefault synchronize];
    
    // update the NSUserDefault so the keyboard need to know that it needs to update
    [self setStatusChanged:YES];
    
    switch (state) {
        case SKPaymentTransactionStatePurchased:
            [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
            break;
        case SKPaymentTransactionStateRestored:
            [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductRestoredNotification object:productIdentifier userInfo:nil];
            break;
        default:
            break;
    }
}

-(void) saveDownloadContent: (SKDownload *) download {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSURL* storeUrl = [fileManager containerURLForSecurityApplicationGroupIdentifier:@"group.com.4-girls-tech.audiots"];
    NSString *myCreationsPlistPath = [[storeUrl path] stringByAppendingPathComponent:@"MyCreations.plist"];
    
    if ([fileManager fileExistsAtPath:myCreationsPlistPath] == NO) {
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"MyCreations" ofType:@"plist"];
        [fileManager copyItemAtPath:resourcePath toPath:myCreationsPlistPath error:&error];
    }
    
    NSString *targetFolder = [storeUrl path];
    
    [self completeTransaction:download.transaction];
}
@end
