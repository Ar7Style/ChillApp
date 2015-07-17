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
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"
@interface HAPaperCollectionViewController () <MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    UIPanGestureRecognizer *pan;
    MPTransition *transitionManager;
    int emptyMessages;
    BOOL loadComplete;
}
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
    
}

- (void)dismissPaperCollection {
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
        
    }else if (recognizer.state==UIGestureRecognizerStateFailed){
        
        [transitionManager cancelInteractiveTransitionWithDuration:.35];
        
    }
}
}
-(void)viewDidAppear:(BOOL)animated{
    if (![self connected]) {
        [self conRefused];
    }
    else {
        self.collectionView.backgroundColor = [UIColor clearColor];
        HUD = [[MBProgressHUD alloc] initWithView:self.collectionView];
        [self.collectionView addSubview:HUD];
        HUD.dimBackground = NO;
        HUD.color = [UIColor clearColor];
        HUD.delegate = self;
        [HUD show:YES];
        [self loadJSON];
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
    
    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=16&size=%0.fx%0.f&scale=2&sensor=true&markers=icon:http://lwts.ru/marker.png|%f,%f", latitude1, longitude1,self.view.frame.size.width,self.view.frame.size.width, latitude1, longitude1];
    return [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (void) loadJSON {
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    NSLog(@"http://api.iamchill.co/v1/messages/index/id_user/%@/id_contact/%li", [userCache valueForKey:@"id_user"], (long)_friendUserID);
//        NSLog(@"http://api.iamchill.co/v1/messages/index/id_user/%@/id_user_to/%li", [userCache valueForKey:@"id_user"], (long)_friendUserID);
        _locations = [[[JSONLoader alloc] init] locationsFromJSONFile:[[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://api.iamchill.co/v1/messages/index/id_user/%@/id_contact/%li", [userCache valueForKey:@"id_user"], (long)_friendUserID]] typeJSON:@"Messages"];
        if (_locations.count == 0 || !_locations.count){
            emptyMessages = 1;
        }
        else {
            emptyMessages = 0;
        }
        self.collectionView.backgroundColor = [UIColor clearColor];
        [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];

    });
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
    
    [HUD hide:YES];
    
    
    if (_friendUserID==1){
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Empty cell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
        cell.layer.cornerRadius = 8;
        cell.clipsToBounds = YES;
        if (indexPath.row==0){
            UIImageView *map = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 259)/2, (self.view.frame.size.height-180)/2-45, 259, 90)];
            [cell addSubview:map];
            map.image = [UIImage imageNamed:@"Oval_43_Oval_44_Line"];
            
            UILabel* name1= [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280)/2, self.view.frame.size.height-180, 280, 110)] ;
            [cell addSubview:name1] ;
            name1.textColor = [UIColor darkGrayColor];
            name1.backgroundColor = [UIColor clearColor];
            name1.numberOfLines = 3;
            name1.textAlignment = NSTextAlignmentCenter;
            name1.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28.0 ];
            name1.text = [NSString stringWithFormat:@"Swipe left\nto see more"];
        }
        else if(indexPath.row==1){
            UIImageView *map = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 96)/2, (self.view.frame.size.height-180)/2-50, 96, 101)];
            [cell addSubview:map];
            map.image = [UIImage imageNamed:@"add_peop_cart"];
            UILabel* name1= [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280)/2, self.view.frame.size.height-180, 280, 110)] ;
            [cell addSubview:name1] ;
            name1.textColor = [UIColor darkGrayColor];
            name1.backgroundColor = [UIColor clearColor];
            name1.numberOfLines = 3;
            name1.textAlignment = NSTextAlignmentCenter;
            name1.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28.0 ];
            name1.text = [NSString stringWithFormat:@"Press this dude\nto add chillers"];

        }
        else if(indexPath.row==2){
            UIImageView *map = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 58)/2, (self.view.frame.size.height-180)/2-50, 58, 101)];
            [cell addSubview:map];
            map.image = [UIImage imageNamed:@"arrow"];
            UILabel* name1= [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280)/2, self.view.frame.size.height-180, 280, 110)] ;
            [cell addSubview:name1] ;
            name1.textColor = [UIColor darkGrayColor];
            name1.backgroundColor = [UIColor clearColor];
            name1.numberOfLines = 3;
            name1.textAlignment = NSTextAlignmentCenter;
            name1.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28.0 ];
            name1.text = [NSString stringWithFormat:@"Swipe the contact\nto send content"];
            
        }

            else if(indexPath.row==3){
                UIImageView *map = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 90)/2,  (self.view.frame.size.height/2)-211, 90, 90)];
                [cell addSubview:map];
                map.image = [UIImage imageNamed:@"Oval 43"];
                
                UIImageView *map1 = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 65)/2,  (self.view.frame.size.height/2)-198, 65, 65)];
                [cell addSubview:map1];
                map1.image = [UIImage imageNamed:@"Oval 44"];
                
                UIImageView *map2 = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 105)/2, (self.view.frame.size.height/2)-123, 105, 247)];
                [cell addSubview:map2];
                map2.image = [UIImage imageNamed:@"Line"];
                
                UILabel* name1= [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280)/2, self.view.frame.size.height-180, 280, 110)] ;
                [cell addSubview:name1] ;
                name1.textColor = [UIColor darkGrayColor];
                name1.backgroundColor = [UIColor clearColor];
                name1.numberOfLines = 3;
                name1.textAlignment = NSTextAlignmentCenter;
                name1.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28.0 ];
                     name1.text = [NSString stringWithFormat:@"Swipe down\nto pause chilling"];
              }
        
        return cell;
    }
        

    
    else {
        if (emptyMessages==0){
            MessagesJSON *location = [_locations objectAtIndex:indexPath.row];
            CHLPaperCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
            cell.friendUserID = self.friendUserID;
            cell.backgroundColor = [UIColor whiteColor];
            
            cell.layer.cornerRadius = 8;
            cell.clipsToBounds = YES;
            cell.cellLabel.minimumScaleFactor = 0.3;
            cell.cellLabel.hidden = true;
            cell.cellLabel.adjustsFontSizeToFitWidth = YES;
            
            if ([location.type isEqualToString:@"location"]) {
                NSString *aString = location.content;
                NSArray *arrayLOC = [aString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                arrayLOC = [arrayLOC filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
                
                NSURL *staticMapImageURL = [self urlOfStaticMapFromLatitude:[arrayLOC[0] doubleValue] longitude:[arrayLOC[1] doubleValue]];
                UIImageView *map = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
                [map setImageWithURL:staticMapImageURL key:nil placeholder:[UIImage imageNamed:@""] completionBlock:nil failureBlock:nil];
                [cell.placeholderContentView addSubview:map];
                
                CLLocationCoordinate2D coord;
                coord.latitude =[arrayLOC[0] doubleValue];
                coord.longitude = [arrayLOC[1] doubleValue];
                GMSReverseGeocodeCallback handler = ^(GMSReverseGeocodeResponse *response, NSError *error) {
                    GMSAddress *addressGMS = response.firstResult;
                    if ( (addressGMS) || ([addressGMS valueForKey:@"thoroughfare"] != nil) ) {
                        cell.cellLabel.text = [NSString stringWithFormat:@"%@",[addressGMS valueForKey:@"thoroughfare"]];
                    } else {
                        cell.cellLabel.text = @"In the middle of nowhere";
                    }
                    cell.cellLabel.hidden = false;
                };
                [geocoder_ reverseGeocodeCoordinate:coord completionHandler:handler];
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];


            } else if ([location.type isEqualToString:@"photo"]) {
                NSString *urlEncodedString = [location.content stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlEncodedString]];
                
                if([location.content isEqualToString:@""]){
                    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageWithData:imageData]];
                    [cell.placeholderContentView addSubview:imageView];
                    cell.cellLabel.text = [self dateStringForUserFromInternalString:location.date_created];
                    cell.cellLabel.hidden = NO;
                }
                else {
                    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"2"]];
                    [cell.placeholderContentView addSubview:imageView];
                }
            }
            else if ([location.type isEqualToString:@"parse"]) {
                if(![location.content isEqualToString:@""]){
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
                    [cell.placeholderContentView addSubview:imageView];
                    imageView.contentMode = UIViewContentModeScaleAspectFill;
                    imageView.clipsToBounds = YES;
                    [imageView setImageWithURL:[NSURL URLWithString:location.content] key:nil placeholder:[UIImage imageNamed:@""] completionBlock:nil failureBlock:nil];
                    cell.cellLabel.text = [self dateStringForUserFromInternalString:location.date_created];
                    cell.cellLabel.hidden = YES;
                }
                else {
                    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"2"]];
                    [cell.placeholderContentView addSubview:imageView];
                }
                cell.backgroundColor = [UIColor whiteColor];
            }
            else if ([location.type isEqualToString:@"icon"]) {
                if(![location.content isEqualToString:@""]){
                    NSDictionary *receivedIconsDictionary = @{@"clock":    @"received_clock",
                                                              @"beer":     @"received_drink",
                                                              @"coffee":   @"received_soda",
                                                              @"stamp":    @"received_blank",
                                                              @"logo":     @"received_logo",
                                                              @"rocket":   @"received_rocket",
                                                              
                                                              @"trophy":    @"received_trophy",
                                                              @"gym":       @"received_gym",
                                                              @"flag":      @"received_flag",
                                                              @"telephone": @"received_telephone",
                                                              @"book":      @"received_book",
                                                              @"waves":     @"received_waves"};
                    
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
                    
                    imageView.backgroundColor = [UIColor whiteColor];
                    [cell.placeholderContentView addSubview:imageView];
                    imageView.contentMode = UIViewContentModeCenter;
                    imageView.clipsToBounds = YES;
                    [imageView setImage:[UIImage imageNamed:[receivedIconsDictionary objectForKey:location.content]]];
                    UIImage* pleaseUpdateImage = [UIImage imageNamed:@"oups"];
                    if (![self isIconWasReceived:receivedIconsDictionary in:location.content]) {

                        imageView.contentMode = UIViewContentModeScaleAspectFit;
                        [imageView setImage:pleaseUpdateImage];
                    }
                    
                    cell.cellLabel.text = [self dateStringForUserFromInternalString:location.date_created];
                    cell.cellLabel.hidden = YES;
                }
                else {
                    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"2"]];
                    [cell.placeholderContentView addSubview:imageView];
                }
                cell.backgroundColor = [UIColor whiteColor];
            }
            return cell;
        }
        else {
            UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Empty cell" forIndexPath:indexPath];
            cell.backgroundColor = [UIColor whiteColor];
            cell.layer.cornerRadius = 8;
            cell.clipsToBounds = YES;
            
            UIImageView *map = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 138)/2, (self.view.frame.size.height - 200)/2, 138, 160)];
            [cell addSubview:map]; // 130 instead 100
            map.image = [UIImage imageNamed:@"Chill_logo1.jpg"];
            /*
            UIWebView *text = [[UIWebView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 300)/2, 280, 300, 100)];
            [cell addSubview:text];
            [text  loadHTMLString:[NSString stringWithFormat:@"<center><p style='font-size:24pt;font-family:HelveticaNeue-Bold'>%@<a style='color:gray;font-family:HelveticaNeue-Light'> wants<br>to chill with you", _nickName] baseURL:nil];
             */
            UILabel* name1= [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280)/2, self.view.frame.size.height-150, 280, 110)] ; //120 instead 90
            [cell addSubview:name1] ;
            name1.textColor = [UIColor darkGrayColor];
            name1.backgroundColor = [UIColor clearColor];
            name1.numberOfLines = 3;
            name1.textAlignment = NSTextAlignmentCenter;
            name1.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28.0 ];
            name1.text = [NSString stringWithFormat:@"Send something to\nstart chilling"];
            return cell;
        }
    }
 
}

-(BOOL)isIconWasReceived: (NSDictionary *)receivedIconsDictionary in: (NSString *)locationContent {
    for (NSString* iconType in receivedIconsDictionary) {
        if ([[NSString stringWithFormat:@"%@", receivedIconsDictionary] containsString: locationContent]) {
            return true;
        }
    }
    return false;
}

//wow, such aMethod
//- (void)aMethod:(id)sender{
//    MessagesJSON *location;
//    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//   // UIButton *clicked = (UIButton *) sender;
////    if (clicked.tag==1){
////        location= [_locations objectAtIndex:0];
////        pasteboard.string = location.code;
////    }
////    else if (clicked.tag ==2) {
////        location= [_locations objectAtIndex:1];
////        pasteboard.string = location.code;
////    }
////    else if (clicked.tag==3){
////        location= [_locations objectAtIndex:2];
////        pasteboard.string = location.code;
////    }
//    HUD = [[MBProgressHUD alloc] initWithView:self.collectionView];
//    [self.collectionView addSubview:HUD];
//    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
//    
//    // Set custom view mode
//    HUD.mode = MBProgressHUDModeCustomView;
//    
//    HUD.delegate = self;
//    HUD.labelText = @"Completed";
//    HUD.color = [UIColor chillMintColor];
//    [HUD show:YES];
//    [HUD hide:YES afterDelay:2];
//}
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
        return 4;
    else{
        if (emptyMessages == 0)
            return _locations.count;
        else
            return 1;
    }
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (emptyMessages == 0 && _friendUserID !=1 ){
        MessagesJSON *location = [_locations objectAtIndex:indexPath.row];
        
        if ([location.type isEqualToString:@"location"]) {
            NSString *aString = location.content;
            NSArray *arrayLOC = [aString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            arrayLOC = [arrayLOC filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
            longitude = [arrayLOC[1] doubleValue];
            latitiude =[arrayLOC[0] doubleValue];
            //[self performSegueWithIdentifier:@"CHLLocationDisplayViewController"
            //                          sender:cellSender];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:latitiude
                                                              longitude:longitude];

            UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CHLLocationDisplayViewController *vc = [storybord instantiateViewControllerWithIdentifier:@"CHLLocationDisplayViewController"];
            vc.location = location;
            [self presentViewController:vc animated:NO completion:nil];
            
        }
        
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
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


