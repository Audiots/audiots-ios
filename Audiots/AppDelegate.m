//
//  AppDelegate.m
//  Audiots
//
//  Created by Bob Ward on 10/30/15.
//  Copyright © 2015 Perfect Sense Digital. All rights reserved.
//

#import "AppDelegate.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <UrbanAirship-iOS-SDK/AirshipLib.h>


@interface AppDelegate () <UAPushNotificationDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Initialize Crashlytics
    [Fabric with:@[[Crashlytics class]]];

    [self urbanAirshipSetup];
    
    
    // Handle launching from a notification
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        // Set icon badge number to zero
        application.applicationIconBadgeNumber = 0;
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // reset
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {

    }

}

#pragma mark - Urban Airship Configuration

- (void) urbanAirshipSetup {
    
    // Populate AirshipConfig.plist with your app's info from https://go.urbanairship.com
    // or set runtime properties here.
    UAConfig *config = [UAConfig defaultConfig];
    
    
    // You can also programmatically override the plist values:
    // config.developmentAppKey = @"YourKey";
    // etc.
    
    config.detectProvisioningMode = YES;
    config.productionAppKey = @"rk7C_MWdS66wggQ8Rr8M8g";
    config.productionAppSecret = @"kJunCV98TBCchRdJkQBkHA";
    config.developmentAppKey = @"C5tRTMhAQdasPygzdlJ0NA";
    config.developmentAppSecret = @"NnIc_f5qRAWAJmWvn4Z8zw";
    
//    NSLog(@"App Key: %@", config.appKey);
//    NSLog(@"App Secret: %@", config.appSecret);
//    NSLog(@"Server: %@", config.deviceAPIURL);
    
    
    // Call takeOff (which creates the UAirship singleton)
    [UAirship takeOff:config];

    
    NSString *channelID = [UAirship push].channelID;
    NSLog(@"My Application Channel ID: %@", channelID);
    
    // Set the notification types required for the app (optional). This value defaults
    // to badge, alert and sound, so it's only necessary to set it if you want
    // to add or remove types.
    [UAirship push].userNotificationTypes = (UIUserNotificationTypeAlert |
                                             UIUserNotificationTypeBadge |
                                             UIUserNotificationTypeSound);
    
    // User notifications will not be enabled until userPushNotificationsEnabled is
    // set YES on UAPush. Once enabled, the setting will be persisted and the user
    // will be prompted to allow notifications. Normally, you should wait for a more
    // appropriate time to enable push to increase the likelihood that the user will
    // accept notifications.
    [UAirship push].userPushNotificationsEnabled = YES;
    
    [UAirship push].pushNotificationDelegate = self;
    
    NSLog(@"Registering for push notifications...");
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *str = [NSString stringWithFormat:@"Device Token=%@",deviceToken];
    NSLog(@"%@", str);
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
    NSLog(@"%@",str);
}


#pragma mark - UAPushNotificationDelegate

- (void)receivedForegroundNotification:(NSDictionary *)notification fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // App received a foreground notification
    
    
    [self postLocalNotification:notification];
    // Call the completion handler
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)launchedFromNotification:(NSDictionary *)notification fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    // App was launched from a notification

    // Call the completion handler
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)launchedFromNotification:(NSDictionary *)notification actionIdentifier:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    // App was launched from a notification action button

    // Call the completion handler
    completionHandler();
}

- (void)receivedBackgroundNotification:(NSDictionary *)notification actionIdentifier:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    // App was launched in the background from a notificaiton action button

    // Call the completion handler
    completionHandler();
}

- (void)receivedBackgroundNotification:(NSDictionary *)notification fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // App received a background notification

    // Call the completion handler
    completionHandler(UIBackgroundFetchResultNoData);
}


#pragma mark - Process Notification

/**
 *  Process push notification
 *
 *  @param notification <#notification description#>
 */
-(void) processPushNotification: (NSDictionary*) notification {
    
    if (notification != nil){
        NSLog(@"notification: %@", notification);
        NSDictionary *aps = notification[@"aps"];
        NSLog(@"aps: %@", aps);
        
    }
}

/**
 *  Post local notification.
 *
 *  @param notification <#notification description#>
 */
-(void) postLocalNotification:(NSDictionary*) notification {
    
    if (notification != nil){
        NSDictionary *aps = notification[@"aps"];
        if (aps != nil) {
            NSString *alertMessage = aps[@"alert"];
            
            if (alertMessage.length > 0) {
                UILocalNotification *localNotification       = [[UILocalNotification alloc] init];
                localNotification.fireDate                   = [NSDate date]; // now
                localNotification.alertBody                  = alertMessage;
                localNotification.soundName                  = UILocalNotificationDefaultSoundName;
                localNotification.applicationIconBadgeNumber = 1;
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            }
        }
    }
}
@end
