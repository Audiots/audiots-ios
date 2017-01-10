//
//  AudiotsInAppRestoreTableViewCell.h
//  Audiots
//
//  Created by Tan Bui on 1/10/17.
//  Copyright © 2017 Perfect Sense Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudiotsIAPHelper.h"

@interface AudiotsInAppRestoreTableViewCell : UITableViewCell


@property (nonatomic, weak) id <InAppDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *restoreButton;
@end
