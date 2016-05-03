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
@property (weak, nonatomic) IBOutlet UITextView *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIButton *buyButton;

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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:IAPHelperProductPurchasedNotification
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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}



#pragma mark - Helpers

-(BOOL) isPremiumPurchased {
    
    return [[AudiotsIAPHelper sharedInstance] productPurchased:@"com.4_girls_tech.audiots.inapp.premium"];
}

/**
 *  Update view for purchase and restore
 */
- (void) updateView {
    
    [[AudiotsIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            
            if (_products.count > 0) {
                
                SKProduct * product = (SKProduct *) _products[0]; // assume that there is only one
                
                [_priceFormatter setLocale:product.priceLocale];
                
                NSLog(@"Buy %@",  [_priceFormatter stringFromNumber:product.price]);
                _titleLabel.text = product.localizedTitle;
                _descriptionLabel.text = product.localizedDescription;
                
                if (self.isPremiumPurchased) {
                    [_buyButton setTitle:@"Purchased" forState:UIControlStateNormal];

                } else {
                    
                    [_buyButton setTitle:[NSString stringWithFormat:@"Buy %@",  [_priceFormatter stringFromNumber:product.price]] forState:UIControlStateNormal];
                }
                [_buyButton sizeToFit];
                
            }
        }
    }];
    
}

- (IBAction)buyAction:(id)sender {

    if (!self.isPremiumPurchased) {
        if (_products.count > 0) {
            SKProduct *product = _products[0];
            
            NSLog(@"Buying %@...", product.productIdentifier);
            [[AudiotsIAPHelper sharedInstance] buyProduct:product];
        }
    }
}
- (IBAction)restoreAction:(id)sender {
    
    [[AudiotsIAPHelper sharedInstance] restoreCompletedTransactions];
}

@end
