//
//  Keyboard.m
//  Audiots
//
//  Created by Tan Bui on 12/29/16.
//  Copyright © 2016 Perfect Sense Digital. All rights reserved.
//


#import "AudiotsKeyboard.h"

@implementation AudiotsKeyboard

+ (BOOL)isOpenAccessGranted
{
    BOOL hasFullAccess = NO;
    
    NSOperatingSystemVersion operatingSystem= [[NSProcessInfo processInfo] operatingSystemVersion];
    
    if (operatingSystem.majorVersion>=10) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = @"Hey";
        
        if (pasteboard.hasStrings) {
            pasteboard.string = @"";
            hasFullAccess = YES;
        }
        else
        {
            pasteboard.string = @"";
            hasFullAccess = NO;
        }
    }
    else
    {
        if ( [UIPasteboard generalPasteboard]) {
            hasFullAccess = YES;
        }
    }
    
    return hasFullAccess;
}

@end
