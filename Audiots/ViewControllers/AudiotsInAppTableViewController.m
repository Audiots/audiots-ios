//
//  AudiotsInAppTableViewController.m
//  Audiots
//
//  Created by Tan Bui on 1/10/17.
//  Copyright © 2017 Perfect Sense Digital. All rights reserved.
//

#import "AudiotsInAppTableViewController.h"
#import "AudiotsIAPHelper.h"
#import "AudiotsInAppTableViewCell.h"
#import "AudiotsInAppRestoreTableViewCell.h"

@interface AudiotsInAppTableViewController ()<InAppDelegate>
{
    NSArray *_products;
}


@end

@implementation AudiotsInAppTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:IAPHelperProductPurchasedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:IAPHelperProductRestoredNotification
                                               object:nil];
    
    _products = nil;
    
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

#pragma mark - Buy and Restore Notification
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_products == nil) {
        return 0;
    } else {
        
        return _products.count + 1; // add the Restore cell
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row < _products.count) {
        return 107;
    } else {
        
        return 60;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    
    if (indexPath.row < _products.count) {
        
        SKProduct * product  = _products[indexPath.row];
        
        AudiotsInAppTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"InAppCell" forIndexPath:indexPath];
        
        [cell setInAppProduct:product];
        cell.delegate = self;
        return cell;
        
    } else {
        
        AudiotsInAppRestoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RestoreCell" forIndexPath:indexPath];
        cell.delegate = self;
        return cell;
    }
    

}


#pragma mark - Helpers

/**
 *  Update view for purchase and restore
 */
- (void) updateView {
    
    [[AudiotsIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        
        if (success) {
            _products = products;
        }
        
        [self.tableView reloadData];
        
    }];
}


-(void) buy:(SKProduct *)product {
    NSLog(@"buying: %@ - %@", product.localizedTitle, product.localizedDescription);
    
    [[AudiotsIAPHelper sharedInstance] buyProduct:product];
}

-(void) restore {
    NSLog(@"restore");
    [[AudiotsIAPHelper sharedInstance] restoreCompletedTransactions];
}
@end
