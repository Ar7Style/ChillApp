//
//  CHLAppDelegate.m
//  Chill
//
//  Copyright (c) Chill. All rights reserved.
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
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import <Crashlytics/Crashlytics.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "UserCache.h"
#import "CHLLocationShareManager.h"
#import "CHLIphoneWCManager.h"

static NSString *const CHLIsOpenedBeforeKey = @"CHLIsOpenedBeforeKey";

@interface CHLAppDelegate ()
@end


@implementation CHLAppDelegate


#pragma mark - UIApplication delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [GMSServices provideAPIKey:@"AIzaSyB0lfyrXe3bodtQ6cAUtCeXR5twEJlolZQ"];
    [Parse setApplicationId:@"vlSSbINvhblgGlipWpUWR6iJum3Q2xd7GthrDVUI" clientKey:@"ZR93BdaHDWTzjIvfDur3X02D3tNs0gATKwY1srh8"];
    [[CHLIphoneWCManager sharedManager] setupSession];
    
    [self registerForAPNS];
    
    [self.window setBackgroundColor:[UIColor whiteColor]];
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor chillMintColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    [userCache setValue:@"0" forKey:@"isEntry"];
    
    //NSURLCache кэширование
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                         diskCapacity:100 * 1024 * 1024
                                                             diskPath:@"NSURLCache"];
    [NSURLCache setSharedURLCache:URLCache];
    
    [Fabric with:@[TwitterKit, CrashlyticsKit]];
    // [self logUser];
    
    // Google Analytics
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 60;
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-59826573-1"];
    
    
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (void)registerForAPNS {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        UIMutableUserNotificationAction *replyAction = [[UIMutableUserNotificationAction alloc] init];
        [replyAction setActivationMode:UIUserNotificationActivationModeForeground];
        [replyAction setTitle:@"Reply"];
        [replyAction setIdentifier:@"Reply"];
        [replyAction setDestructive:NO];
        [replyAction setAuthenticationRequired:NO];
        
        UIMutableUserNotificationAction *locationAction = [[UIMutableUserNotificationAction alloc] init];
        [locationAction setActivationMode:UIUserNotificationActivationModeBackground];
        [locationAction setTitle:@"Reply 📍"];
        [locationAction setIdentifier:@"ReplyLocation"];
        [locationAction setAuthenticationRequired:NO];
        
        UIMutableUserNotificationCategory *actionCategory = [[UIMutableUserNotificationCategory alloc] init];
        [actionCategory setIdentifier:@"actionable"];
        [actionCategory setActions:@[replyAction, locationAction] forContext:UIUserNotificationActionContextMinimal];
        [actionCategory setActions:@[replyAction, locationAction] forContext:UIUserNotificationActionContextDefault];
        
        NSSet *categories = [NSSet setWithObject:actionCategory];
        
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

//just example
- (void) logUser {
    // TODO: Use the current user's information
    // You can call any combination of these three methods
    [CrashlyticsKit setUserIdentifier:@"12345"];
    [CrashlyticsKit setUserEmail:@"user@fabric.io"];
    [CrashlyticsKit setUserName:@"Test User from AppDelegate"];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

//For interactive notification only
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    if ([identifier isEqualToString:@"Reply"]) {
        
    }
    else if ([identifier isEqualToString:@"ReplyLocation"]) {
        [[CHLLocationShareManager sharedManager] shareLocationWithUser:[[userInfo objectForKey:@"fromUserId"] integerValue]];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    //    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    //    [userCache synchronize];
    
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

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
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
