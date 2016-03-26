//
//  AudiotsHomeTableViewController.m
//  audiots
//
//  Created by Bob Ward on 10/27/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import "AudiotsHomeTableViewController.h"

#import "AudiotsFeedbackTableViewCell.h"
#import "AudiotsRateUsTableViewCell.h"

@interface AudiotsHomeTableViewController ()
@property (strong, nonatomic) MFMailComposeViewController *mailComposeViewController;
@end

@implementation AudiotsHomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    switch (section) {
        case 0:
            numberOfRows = 6;
            break;
            
        default:
            break;
    }
    return numberOfRows;
}

#pragma mark - TableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[AudiotsFeedbackTableViewCell class]]) {
        self.mailComposeViewController = [[MFMailComposeViewController alloc] init];
        if ([MFMailComposeViewController canSendMail] == YES) {
            NSString *emailTitle = @"Audiots Feedback";
            NSMutableString *messageBody = [[NSMutableString alloc] init];
            [messageBody appendString:@"Device information\n"];
            [messageBody appendFormat:@"Device model: %@\n", [[UIDevice currentDevice] model]];
            [messageBody appendFormat:@"iOS Version: %@\n", [[UIDevice currentDevice] systemVersion]];
            [messageBody appendFormat:@"Application version: %@.%@\n", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                                                                        [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
            
            self.mailComposeViewController.mailComposeDelegate = self;
            [self.mailComposeViewController setSubject:emailTitle];
            [self.mailComposeViewController setMessageBody:messageBody isHTML:NO];
            [self.mailComposeViewController setToRecipients:@[@"d@4girlstech.com"]];
            [self presentViewController:self.mailComposeViewController animated:YES completion:NULL];
        } else {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Info"
                                                                                      message:@"Unable to send email from this device."
                                                                               preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alertController dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alertController dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
            
            [alertController addAction:okAction];
            [alertController addAction:cancelAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    } else if ([cell isKindOfClass:[AudiotsRateUsTableViewCell class]]) {
        NSString *str;
        NSString *appID = @"1078710105";
        float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (ver >= 7.0 && ver < 7.1) {
            str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appID];
        } else if (ver >= 8.0) {
            str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software",appID];
        } else {
            str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",appID];
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:^{
        self.mailComposeViewController = nil;
    }];
}

@end
