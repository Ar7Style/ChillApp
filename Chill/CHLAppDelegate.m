//
//  CHLAppDelegate.m
//  Chill
//
//  Created by Михаил Луцкий on 5/7/14.
//  Copyright (c) 2014 Mikhail Loutskiy. All rights reserved.
//


#import "CHLAppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import "UIColor+ChillColors.h"
#import "AUTHViewController.h"
#import <Parse/Parse.h>
#import "HAPaperCollectionViewController.h"
#import "HACollectionViewLargeLayout.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"
static NSString *const CHLIsOpenedBeforeKey = @"CHLIsOpenedBeforeKey";

@interface CHLAppDelegate ()
@end


@implementation CHLAppDelegate


#pragma mark - UIApplication delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"\n\n\n*******************************************\nWELCOME TO CHILL APP\nDevelopers: Tareyev Gregory & Loutskiy Mikhail\n2015 (с) Copyright Chill. All rights reserved.");
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [GMSServices provideAPIKey:@"AIzaSyB0lfyrXe3bodtQ6cAUtCeXR5twEJlolZQ"];
    [Parse setApplicationId:@"vlSSbINvhblgGlipWpUWR6iJum3Q2xd7GthrDVUI" clientKey:@"ZR93BdaHDWTzjIvfDur3X02D3tNs0gATKwY1srh8"];
    
    
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge)];
//        // iOS < 8 Notifications
//        [application registerForRemoteNotificationTypes:
//         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    [self.window setBackgroundColor:[UIColor whiteColor]];
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor chillMintColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    if (![userCache boolForKey:@"Initilized invites"]) {
        [userCache setInteger:3 forKey:@"Available invites number"];
        [userCache setBool:YES forKey:@"Initilized invites"];
    }
    
    //NSURLCache кэширование
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                         diskCapacity:100 * 1024 * 1024
                                                             diskPath:@"NSURLCache"];
    [NSURLCache setSharedURLCache:URLCache];
    
    // Google Analytics
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 60;
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-59826573-1"];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

//For interactive notification only
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    // ...
}
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
    } else {
        // show some alert or otherwise handle the failure to register.
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //[PFPush handlePush:userInfo];
    NSLog(@"Received notification: %@", userInfo);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([userDefaults integerForKey:@"PUSH"]==0){
        NSDictionary *aps = (NSDictionary *)[userInfo objectForKey:@"aps"];
        //NSMutableString *alert = [NSMutableString stringWithString:@""];
        if ([aps objectForKey:@"alert"])
        {
            //[alert appendString:(NSString *)[aps objectForKey:@"alert"]];
        }
        if (application.applicationState == UIApplicationStateBackground) {
            if ([[userInfo objectForKey:@"type"] isEqualToString:@"Location"]){
                UIViewController *rootController = (UIViewController *)self.window.rootViewController;
                HAPaperCollectionViewController *myNewVC = [[HAPaperCollectionViewController alloc] init];
                HACollectionViewLargeLayout *aFlowLayout = [[HACollectionViewLargeLayout alloc] init];
                myNewVC = [[HAPaperCollectionViewController alloc]initWithCollectionViewLayout:aFlowLayout];
                myNewVC.friendUserID =  [[userInfo objectForKey:@"fromUserId"] integerValue];
                [rootController presentViewController:myNewVC animated:YES completion:NULL];
            }
            else if ([[userInfo objectForKey:@"type"] isEqualToString:@"Photo"]){
                UIViewController *rootController = (UIViewController *)self.window.rootViewController;
                HAPaperCollectionViewController *myNewVC = [[HAPaperCollectionViewController alloc] init];
                HACollectionViewLargeLayout *aFlowLayout = [[HACollectionViewLargeLayout alloc] init];
                myNewVC = [[HAPaperCollectionViewController alloc]initWithCollectionViewLayout:aFlowLayout];
                myNewVC.friendUserID =  [[userInfo objectForKey:@"fromUserId"] integerValue];
                [rootController presentViewController:myNewVC animated:YES completion:NULL];
            }
        }
    }
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}





@end
