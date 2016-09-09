//
//  AudiotsInAppTableViewController.m
//  Audiots
//
//  Created by Tan Bui on 5/2/16.
//  Copyright © 2016 Perfect Sense Digital. All rights reserved.
//

#import "AudiotsInAppTableViewController.h"
#import "AudiotsIAPHelper.h"

@interface AudiotsInAppTableViewController ()
{
    NSArray *_products;
    NSNumberFormatter * _priceFormatter;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;


// See Jane
@property (weak, nonatomic) IBOutlet UILabel *sjTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sjDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *sjBuyButton;


@end

@implementation AudiotsInAppTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    
    
//    _buyButton.layer.cornerRadius = 10; // this value vary as per your desire
//    _buyButton.clipsToBounds = YES;
//    
//    _sjBuyButton.layer.cornerRadius = 10; // this value vary as per your desire
//    _sjBuyButton.clipsToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:IAPHelperProductPurchasedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:IAPHelperProductRestoredNotification
                                               object:nil];
    
    [self updateView];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void) receiveNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:IAPHelperProductPurchasedNotification]){
        NSLog (@"Successfully received the IAPHelperProductPurchasedNotification notification!");
        
        [self updateView];
    }
    
    if ([[notification name] isEqualToString:IAPHelperProductRestoredNotification]){
        NSLog (@"Successfully received the IAPHelperProductRestoredNotification notification!");
        
        [self showAlertWithTitle:@"Restore" andMessage:@"Successfully restored previous purchases."];

    }
    
   
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}



#pragma mark - Helpers

/**
 *  Update view for purchase and restore
 */
- (void) updateView {
    
    [[AudiotsIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            
            for (SKProduct * product in _products) {
                
                if ([product.productIdentifier isEqualToString:kInAppIdPremium]) {
                    // premium
                    [_priceFormatter setLocale:product.priceLocale];
                    
                    _titleLabel.text = product.localizedTitle;
                    _descriptionLabel.text = product.localizedDescription;
                    
                    
                    if ([[AudiotsIAPHelper sharedInstance] productPurchased:kInAppIdPremium]) {
                        [_buyButton setTitle:@"Paid" forState:UIControlStateNormal];
                        
                    } else {
                        
                        [_buyButton setTitle:[NSString stringWithFormat:@"%@",  [_priceFormatter stringFromNumber:product.price]] forState:UIControlStateNormal];
                    }
                    [_buyButton sizeToFit];
                } else if ([product.productIdentifier isEqualToString:kInAppIdSeeJane]) {
                    // see jane
                    [_priceFormatter setLocale:product.priceLocale];
                    
                    _sjTitleLabel.text = product.localizedTitle;
                    _sjDescriptionLabel.text = product.localizedDescription;
                    
                    
                    if ([[AudiotsIAPHelper sharedInstance] productPurchased:kInAppIdSeeJane]) {
                        [_sjBuyButton setTitle:@"Paid" forState:UIControlStateNormal];
                        
                    } else {
                        
                        [_sjBuyButton setTitle:[NSString stringWithFormat:@"%@",  [_priceFormatter stringFromNumber:product.price]] forState:UIControlStateNormal];
                    }
                    [_sjBuyButton sizeToFit];
                    
                }
                
            }
            
        }
    }];
    
}

- (IBAction)buyAction:(id)sender {

    if (![[AudiotsIAPHelper sharedInstance] productPurchased:kInAppIdPremium]) {
        if (_products.count > 0) {
            SKProduct *product = _products[0];
            
            NSLog(@"Buying %@...", product.productIdentifier);
            [[AudiotsIAPHelper sharedInstance] buyProduct:product];
        }
    }
}

- (IBAction)sjBuyAction:(id)sender {
    if (![[AudiotsIAPHelper sharedInstance] productPurchased:kInAppIdSeeJane]) {
        if (_products.count > 0) {
            SKProduct *product = _products[1];
            
            NSLog(@"Buying %@...", product.productIdentifier);
            [[AudiotsIAPHelper sharedInstance] buyProduct:product];
        }
    }
    
}


- (IBAction)restoreAction:(id)sender {
    
    [[AudiotsIAPHelper sharedInstance] restoreCompletedTransactions];
}

- (void) showAlertWithTitle: (NSString*) title andMessage: (NSString*) message {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [self updateView];
                                                    }];
    
    [alertController addAction:okButton];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

@end
