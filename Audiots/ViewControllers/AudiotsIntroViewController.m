//
//  AudiotsIntroViewController.m
//  Audiots
//
//  Created by Bob Ward on 11/16/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import "AudiotsIntroViewController.h"

@interface AudiotsIntroViewController ()

@end

@implementation AudiotsIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [self.versionLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Version: %@ (%@)", @"Version: %@ (%@)"), appVersionString, appBuildString]];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
