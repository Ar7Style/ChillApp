//
//  HAPaperCollectionViewController.m
//  Paper
//
//  Created by Heberti Almeida on 11/02/14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//
#import "HAPaperCollectionViewController.h"
#define CELL_ID @"CELL_ID"
#import "MessagesJSON.h"
#import "JSONLoader.h"
#import "JMImageCache.h"
#import "SVPullToRefresh.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "CHLLocationDisplayViewController.h"
#import "CHLShareViewController.h"
#import "CHLPaperCollectionCell.h"
#import "UIColor+ChillColors.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>
#import "MPTransition.h"
#import "UserCache.h"

#import <AFNetworking/AFNetworking.h>
#import "UIButton+AFNetworking.h"
#import "SCLAlertView.h"

#import "CHLDisplayPhotoViewController.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"


@implementation ButtonToShow

@end

@interface HAPaperCollectionViewController () <MBProgressHUDDelegate>{
    NSArray *json;
    MBProgressHUD *HUD;
    UIPanGestureRecognizer *pan;
    MPTransition *transitionManager;
}

@property (weak, nonatomic) IBOutlet UIImageView *photoSpace;

@end


@implementation HAPaperCollectionViewController {
    NSArray *firstArray;
    NSArray *_locations;
    GMSGeocoder *geocoder_;

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void) conRefused {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Connection refused"
                                                                   message:@"Check your Internet connection"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {}];
    [alert addAction:okayAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)connected
{
    return [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable;
}

-(void)viewDidLoad{
    geocoder_ = [[GMSGeocoder alloc] init];
    transitionManager=[[MPTransition alloc] init];
    self.transitioningDelegate=transitionManager;
    
    pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:pan];
    self.navigationController.view.layer.cornerRadius=6;
    self.navigationController.view.clipsToBounds=YES;
    
    UIButton* closeButton = [[UIButton alloc]init];
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if ([[UIScreen mainScreen] bounds].size.height <= 568) // <= iphone 5
        {
            closeButton.frame = CGRectMake(232, 35, 100, 30);
            [closeButton setImage:[UIImage imageNamed:@"x-2"] forState:UIControlStateNormal];
            [closeButton addTarget:self action:@selector(dismissPaperCollection:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:closeButton];
           
        }
        
        
        else if ([UIScreen mainScreen].scale >= 2.9) // >= iphone 6 plus
        {
            closeButton.frame = CGRectMake(337, 35, 100, 30);
            [closeButton setImage:[UIImage imageNamed:@"x-2"] forState:UIControlStateNormal];
            [closeButton addTarget:self action:@selector(dismissPaperCollection:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:closeButton];
        }
        
        else { // iphone 6
            closeButton.frame = CGRectMake(289, 35, 100, 30);
            [closeButton setImage:[UIImage imageNamed:@"x-2"] forState:UIControlStateNormal];
            [closeButton addTarget:self action:@selector(dismissPaperCollection:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:closeButton];
            
        }
    }
    
}

- (void)dismissPaperCollection:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [transitionManager updateInteractiveTransition:0];
    [self performSelector:@selector(finishDismissing) withObject:nil afterDelay:0.03];
}

- (void)finishDismissing {
    [transitionManager updateInteractiveTransition:0];
    [transitionManager finishInteractiveTransitionWithDuration:0.4];
}

- (void)pan:(UIPanGestureRecognizer *)recognizer{
    CGPoint velocity = [recognizer velocityInView:self.view];
    
    if (velocity.y){   // panning down
    if (recognizer.state==UIGestureRecognizerStateBegan){
        [self dismissViewControllerAnimated:YES completion:NULL];
        [recognizer setTranslation:CGPointZero inView:self.view.superview];
        [transitionManager updateInteractiveTransition:0];
        return;
    }
    
    CGFloat percentage = [recognizer translationInView:self.view.superview].y/self.view.superview.bounds.size.height;
    
    [transitionManager updateInteractiveTransition:percentage];
    
    if (recognizer.state==UIGestureRecognizerStateEnded) {
        
        CGFloat velocityY = [recognizer velocityInView:recognizer.view.superview].y;
        BOOL cancel=(velocityY<0) || (velocityY==0 && recognizer.view.frame.origin.y<self.view.superview.bounds.size.height/2);
        CGFloat points = cancel ? recognizer.view.frame.origin.y : self.view.superview.bounds.size.height-recognizer.view.frame.origin.y;
        NSTimeInterval duration = points / velocityY;
        
        if (duration<.2) {
            duration=.2;
        }else if(duration>.6){
            duration=.6;
        }
        
        cancel ? [transitionManager cancelInteractiveTransitionWithDuration:duration] : [transitionManager finishInteractiveTransitionWithDuration:duration];
        
    } else if (recognizer.state==UIGestureRecognizerStateFailed){
        
        [transitionManager cancelInteractiveTransitionWithDuration:.35];
        
    }
}
}
-(void)viewDidAppear:(BOOL)animated{
    if (![self connected]) {
        SCLAlertView* alert = [[SCLAlertView alloc] init];
        [alert showError:self.parentViewController title:@"Failed" subTitle:@"Please, check your internet connection" closeButtonTitle:@"OK" duration:0.0f];

    }
    else {
        self.collectionView.backgroundColor = [UIColor clearColor];
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Cards screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void)handleSwipeGesture:(UISwipeGestureRecognizer *) sender
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    [self dismissViewControllerAnimated:YES completion:nil];

    //Gesture detect - swipe up/down , can't be recognized direction
}

- (NSURL *)urlOfStaticMapFromLatitude:(CGFloat)latitude1 longitude:(CGFloat)longitude1 {
    
    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=16&size=%0.fx%0.f&scale=2&sensor=true&markers=icon:http://i11.pixs.ru/storage/2/9/4/location2x_8770259_18071294.png|%f,%f", latitude1, longitude1,self.view.frame.size.width,self.view.frame.size.width, latitude1, longitude1];
    return [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (id)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    if (self = [super initWithCollectionViewLayout:layout])
    {
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Empty cell"];
        [self.collectionView registerNib:[UINib nibWithNibName:@"CHLPaperCollectionCell" bundle:nil]  forCellWithReuseIdentifier:CELL_ID];
        [self.collectionView setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

#pragma mark - Hide StatusBar
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (_friendUserID==1){ //How to Chill
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Empty cell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
        cell.layer.cornerRadius = 8;
        cell.clipsToBounds = YES;
        if (indexPath.row==0){
            UIImageView *map = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, self.view.frame.size.height)];
            map.contentMode = UIViewContentModeScaleAspectFit;
            [cell addSubview:map];
            map.image = [UIImage imageNamed:@"chill_edu1"];
        }
        else if(indexPath.row==1){
            UIImageView *map = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, self.view.frame.size.height)];
            map.contentMode = UIViewContentModeScaleAspectFit;
            [cell addSubview:map];
            map.image = [UIImage imageNamed:@"chill_edu2"];
        }
        return cell;
    }
    
    else {
            CHLPaperCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
            cell.textLabel1.tag = 1;
            cell.textLabel2.tag = 2;
            cell.textLabel3.tag = 3;
            cell.textLabel4.tag = 4;
            cell.textLabel5.tag = 5;
        for (ButtonToShow* button in cell.buttonsToShow)
            [button setHidden:YES];
        
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            [manager.requestSerializer setValue:[NSUserDefaults userToken] forHTTPHeaderField:@"X-API-TOKEN"];
            [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
            [manager GET:[NSString stringWithFormat:@"http://api.iamchill.co/v2/messages/index/id_user/%@/id_contact/%ld",[NSUserDefaults userID], (long)_friendUserID] parameters:nil success:^(NSURLSessionTask *task, id responseObject) {
                if ([[responseObject objectForKey:@"status"] isEqualToString:@"success"]) {
                    json = [responseObject objectForKey:@"response"];
                    
                    
                    for (int i=0; i<json.count; ++i) {
                        UILabel* textLabel = (UILabel *)[cell viewWithTag:i+1];
                        [cell.buttonsToShow[i] setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:[json[i] valueForKey:@"size66"]]];
                        [cell.buttonsToShow[i] setHidden:NO];
                        if ([[json[i] valueForKey:@"type"] isEqualToString:@"location"]) {
                            ButtonToShow* myButton = cell.buttonsToShow[i];
                            myButton.locationData = [json[i] valueForKey:@"content"];
                            [cell.buttonsToShow[i] addTarget:self action:@selector(displayMap:) forControlEvents:UIControlEventTouchUpInside];
                            
                            NSString *aString = [json[i] valueForKey:@"content"];
                            NSArray *arrayLOC = [aString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            arrayLOC = [arrayLOC filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];

                            CLLocationCoordinate2D coord;
                            coord.latitude =[arrayLOC[0] doubleValue];
                            coord.longitude = [arrayLOC[1] doubleValue];
                            GMSReverseGeocodeCallback handler = ^(GMSReverseGeocodeResponse *response, NSError *error) {
                                GMSAddress *addressGMS = response.firstResult;
                                if ( (addressGMS) || ([addressGMS valueForKey:@"thoroughfare"] != nil) ) {
                                    textLabel.text = [NSString stringWithFormat:@"%@",[addressGMS valueForKey:@"thoroughfare"]];
                                } else {
                                    textLabel.text = @"In the middle of nowhere";
                                }
                            };
                            [geocoder_ reverseGeocodeCoordinate:coord completionHandler:handler];
                            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
                        }
                        else if ([[json[i] valueForKey:@"type"] isEqualToString:@"parse"]) {
                            ButtonToShow *myButton = cell.buttonsToShow[i];
                            myButton.linkToIconImage = [json[i] valueForKey:@"content"];
                            [cell.buttonsToShow[i] addTarget:self action:@selector(displayPhoto:) forControlEvents:UIControlEventTouchUpInside];
                            textLabel.text = [NSString stringWithFormat:@"Press to open"];
                        }
                        else {
                        textLabel.text = [NSString stringWithFormat:@"%@", [[json[i] valueForKey:@"text"] isEqualToString:@""] ? @"" :[NSString stringWithFormat:@"#%@",[json[i] valueForKey:@"text"]]];
                        }
                    }
                }
                NSLog(@"JSON FROM LOAD DATA: %@", json);
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [self dismissViewControllerAnimated:NO completion:nil];
                NSLog(@"Error from load data: %@", error);
            }];
        
            cell.friendUserID = self.friendUserID;
            cell.backgroundColor = [UIColor whiteColor];
            
            cell.layer.cornerRadius = 8;
            cell.clipsToBounds = YES;
            cell.cellLabel.minimumScaleFactor = 0.3;
            cell.cellLabel.hidden = true;
            cell.cellLabel.adjustsFontSizeToFitWidth = YES;
    
            cell.backgroundColor = [UIColor whiteColor];
        
        
        [cell.replyButton addTarget:self action:@selector(goToShareVC:) forControlEvents:UIControlEventTouchUpInside];
         
        
            return cell;
        }
}

-(void)goToShareVC:(id)sender {
    NSLog(@"gotoshareVC");
    CHLShareViewController* svc = [[CHLShareViewController alloc] init];
    svc.userIdTo = (long)_friendUserID;
    svc.nameUser = self.nickName;
    NSLog(@"LOGIN: %@ IDUSER: %ld", svc.nameUser, (long)svc.userIdTo);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    UIViewController *shareViewController = (UIViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"shareViewController"];
    [self presentViewController:shareViewController animated:YES completion:nil];
}

-(void) displayMap:(ButtonToShow *)sender {
    
            NSString *aString = sender.locationData;
            NSArray *arrayLOC = [aString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            arrayLOC = [arrayLOC filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
            
            NSURL *staticMapImageURL = [self urlOfStaticMapFromLatitude:[arrayLOC[0] doubleValue] longitude:[arrayLOC[1] doubleValue]];
            UIImageView *map = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
            [map setImageWithURL:staticMapImageURL key:nil placeholder:[UIImage imageNamed:@""] completionBlock:nil failureBlock:nil];
            
            longitude = [arrayLOC[1] doubleValue];
            latitiude = [arrayLOC[0] doubleValue];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:latitiude
                                                              longitude:longitude];
            
            UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CHLLocationDisplayViewController *vc = [storybord instantiateViewControllerWithIdentifier:@"CHLLocationDisplayViewController"];
            vc.location = location;
            [self presentViewController:vc animated:NO completion:nil];

    
    
}

-(void) displayPhoto:(ButtonToShow *)sender {
    
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CHLDisplayPhotoViewController *dpvc = [storyboard instantiateViewControllerWithIdentifier:@"CHLDisplayPhotoViewController"];
            dpvc.urlOfImage = sender.linkToIconImage;
    
            [self presentViewController:dpvc animated:NO completion:nil];
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
{
    UICollectionViewCell *cell1 = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    UICollectionViewCell *cell2 = [collectionView dequeueReusableCellWithReuseIdentifier:@"Empty cell" forIndexPath:indexPath];
    cell= nil;
    cell1=nil;
    cell2 = nil;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(_friendUserID==1)
        return 2;
    else{
            return 1;
    }
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewController*)nextViewControllerAtPoint:(CGPoint)point
{
    return nil;
}

- (NSString *)dateStringForUserFromInternalString:(NSString *)internalDateString {
    return internalDateString;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.collectionView.backgroundColor = [UIColor clearColor];
    // Adjust scrollView decelerationRate
    self.collectionView.decelerationRate = self.class != [HAPaperCollectionViewController class] ? UIScrollViewDecelerationRateNormal : UIScrollViewDecelerationRateFast;
}


@end


