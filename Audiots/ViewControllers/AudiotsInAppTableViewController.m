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
    
    
    [[AudiotsIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            
            if (_products.count > 0) {
            
                SKProduct * product = (SKProduct *) _products[0]; // assume that there is only one
                
                [_priceFormatter setLocale:product.priceLocale];
                
                NSLog(@"Buy %@",  [_priceFormatter stringFromNumber:product.price]);
                _titleLabel.text = product.localizedTitle;
                _descriptionLabel.text = product.localizedDescription;
                
                [_buyButton setTitle:[NSString stringWithFormat:@"Buy %@",  [_priceFormatter stringFromNumber:product.price]] forState:UIControlStateNormal];
                [_buyButton sizeToFit];
                
            }
        }
    }];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (IBAction)buyAction:(id)sender {

    if (_products.count > 0) {
        SKProduct *product = _products[0];
        
        NSLog(@"Buying %@...", product.productIdentifier);
        [[AudiotsIAPHelper sharedInstance] buyProduct:product];
    }
}
- (IBAction)restoreAction:(id)sender {
    
    [[AudiotsIAPHelper sharedInstance] restoreCompletedTransactions];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
