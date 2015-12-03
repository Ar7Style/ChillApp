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
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"

@interface HAPaperCollectionViewController () <MBProgressHUDDelegate>{
     NSArray *json;
    NSIndexPath* currentIndexPath;
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
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
       
        UIButton* closeButton = [[UIButton alloc]init];
        if ([[UIScreen mainScreen] bounds].size.height <= 568) // <= iphone 5
        {
            closeButton.frame = CGRectMake(232, 35, 100, 30);
            [closeButton setImage:[UIImage imageNamed:@"x-2"] forState:UIControlStateNormal];
            [closeButton addTarget:self action:@selector(dismissPaperCollection:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:closeButton];
           
        }
        
        
        else if ([UIScreen mainScreen].scale >= 2.9) // >= iphone 6plus
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
   // [self loadData];
    
    
}

//- (void) loadData:(NSIndexPath *)indexPath withCollectionView:(UICollectionView *)collectionView{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    [manager.requestSerializer setValue:[NSUserDefaults userToken] forHTTPHeaderField:@"X-API-TOKEN"];
//    [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
//    [manager GET:[NSString stringWithFormat:@"http://api.iamchill.co/v2/icons/index/id_user/%@", [NSUserDefaults userID]] parameters:nil success:^(NSURLSessionTask *task, id responseObject) {
//        if ([[responseObject objectForKey:@"status"] isEqualToString:@"success"]) {
//            json = [responseObject objectForKey:@"response"];
//            CHLPaperCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
//            [cell.icon3 setHidden:NO];
//            //[self setIcons:indexPath withCollectionView:collectionView];
//
//        }
//        NSLog(@"JSON FROM LOAD DATA: %@", [json[0] valueForKey:@"size42"]);
//            } failure:^(NSURLSessionTask *operation, NSError *error) {
//        [self dismissViewControllerAnimated:NO completion:nil];
//        NSLog(@"Error from load data: %@", error);
//    }];
//}

- (void) setIcons:(NSIndexPath *)indexPath withCollectionView:(UICollectionView *)collectionView {
    CHLPaperCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    [cell.icon3 setHidden:NO];
    [cell.icon1 setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[0] valueForKey:@"size42"]]]] forState:UIControlStateNormal];
    NSLog(@"icons must be setten");
//    [cell.icon2 setBackgroundImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[1] valueForKey:@"size80"]]]];
//    [_icon3 setBackgroundImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[2] valueForKey:@"size80"]]]];
//    [_icon4 setBackgroundImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[3] valueForKey:@"size80"]]]];
//    [_icon5 setBackgroundImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[4] valueForKey:@"size80"]]]];
//    [_icon6 setBackgroundImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[0] valueForKey:@"size80"]]]];
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
        
//        HUD = [[MBProgressHUD alloc] initWithView:self.collectionView];
//        [self.collectionView addSubview:HUD];
//        HUD.dimBackground = NO;
//        HUD.color = [UIColor clearColor];
//        HUD.delegate = self;
//        [HUD show:YES];
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

//- (void) loadJSON {
//    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
////        NSLog(@"http://api.iamchill.co/v2/messages/index/id_user/%@/id_user_to/%li", [userCache valueForKey:@"id_user"], (long)_friendUserID);
//        _locations = [[[JSONLoader alloc] init] locationsFromJSONFile:[[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://api.iamchill.co/v2/messages/index/id_user/%@/id_contact/%li", [userCache valueForKey:@"id_user"], (long)_friendUserID]] typeJSON:@"Messages"];
//        if (_locations.count == 0 || !_locations.count){
//            emptyMessages = 1;
//        }
//        else {
//            emptyMessages = 0;
//        }
//        self.collectionView.backgroundColor = [UIColor clearColor];
//        [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
//
//    });
//}



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
    currentIndexPath = indexPath;
    [HUD hide:YES];
    
    
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
        if (emptyMessages==0){
            MessagesJSON *location = [_locations objectAtIndex:indexPath.row];
            CHLPaperCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
            [cell.icon2 setHidden:YES];
            [cell.icon3 setHidden:YES];
            [cell.icon4 setHidden:YES];
            [cell.icon5 setHidden:YES];
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            [manager.requestSerializer setValue:[NSUserDefaults userToken] forHTTPHeaderField:@"X-API-TOKEN"];
            [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
            [manager GET:[NSString stringWithFormat:@"http://api.iamchill.co/v2/messages/index/id_user/%@/id_contact/%ld",[NSUserDefaults userID], (long)_friendUserID] parameters:nil success:^(NSURLSessionTask *task, id responseObject) {
                if ([[responseObject objectForKey:@"status"] isEqualToString:@"success"]) {
                    json = [responseObject objectForKey:@"response"];
                    
                    [cell.icon1 setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[0] valueForKey:@"size42"]]]] forState:UIControlStateNormal];
                    cell.textLabel1.text = [NSString stringWithFormat:@"%@", [[json[0] valueForKey:@"text"] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"#%@",[json[0] valueForKey:@"text"]]];
                    
                    [cell.icon2 setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[1] valueForKey:@"size42"]]]] forState:UIControlStateNormal];
                    cell.textLabel2.text = [NSString stringWithFormat:@"%@", [[json[1] valueForKey:@"text"] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"#%@",[json[1] valueForKey:@"text"]]];
                    
                    [cell.icon3 setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[2] valueForKey:@"size42"]]]] forState:UIControlStateNormal];
                    cell.textLabel3.text = [NSString stringWithFormat:@"%@", [[json[2] valueForKey:@"text"] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"#%@",[json[2] valueForKey:@"text"]]];
                    
                    [cell.icon4 setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[3] valueForKey:@"size42"]]]] forState:UIControlStateNormal];
                    cell.textLabel4.text =[NSString stringWithFormat:@"%@", [[json[3] valueForKey:@"text"] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"#%@",[json[3] valueForKey:@"text"]]];
                    
                    [cell.icon5 setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[4] valueForKey:@"size42"]]]] forState:UIControlStateNormal];
                    cell.textLabel5.text = [NSString stringWithFormat:@"%@", [[json[4] valueForKey:@"text"] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"#%@",[json[4] valueForKey:@"text"]]];
                    
                    [cell.icon2 setHidden:NO];
                    [cell.icon3 setHidden:NO];
                    [cell.icon4 setHidden:NO];
                    [cell.icon5 setHidden:NO];
                    
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
                  //  imageView.contentMode = UIViewContentModeScaleAspectFit; //Fill
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
                    NSDictionary *receivedIconsDictionary = @{@"clock":      @"received_clock",
                                                              @"beer":       @"received_drink",
                                                              @"coffee":     @"received_soda",
                                                              @"question":   @"received_question",
                                                              @"logo":       @"received_logo",
                                                              @"rocket":     @"received_rocket",
                                                              @"stamp":      @"received_blank",
                                                              
                                                              @"trophy":     @"received_trophy",
                                                              @"gym":        @"received_gym",
                                                              @"flag":       @"received_flag",
                                                              @"telephone":  @"received_telephone",
                                                              @"book":       @"received_book",
                                                              @"waves":      @"received_waves",
                                                              
                                                              @"plus":       @"received_plus",
                                                              @"minus":      @"received_minus",
                                                              @"dollar":     @"received_dollar",
                                                              @"sleep":      @"received_sleep",
                                                              @"pizza":      @"received_pizza",
                                                              @"ball":       @"received_ball",
                                                              @"heart":      @"received_heart",
                                                              @"controller": @"received_controller"};
                    
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
                    
                    imageView.backgroundColor = [UIColor whiteColor];
                    [cell.placeholderContentView addSubview:imageView];
                    imageView.contentMode = UIViewContentModeCenter;
                    imageView.clipsToBounds = YES;
                    [imageView setImage:[UIImage imageNamed:[receivedIconsDictionary objectForKey:location.content]]];
                    cell.cellLabel.font = [UIFont systemFontOfSize:25];
                    cell.cellLabel.textColor = [UIColor chillDarkGrayColor];
                    
                    cell.cellLabel.text = [NSString stringWithFormat:@"%@", [location.text isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"#%@", location.text]];
                    

                    UIImage* pleaseUpdateImage = [UIImage imageNamed:@"oups"];
                    if (![self isIconWasReceived:receivedIconsDictionary in:location.content]) {

                        imageView.contentMode = UIViewContentModeScaleAspectFit;
                        [imageView setImage:pleaseUpdateImage];
                    }
                    
                   // cell.cellLabel.text = [self dateStringForUserFromInternalString:location.date_created];
                    cell.cellLabel.hidden = NO;
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
            
            UIImageView *map = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height)];
            [cell addSubview:map]; // 130 instead 100
            map.contentMode = UIViewContentModeScaleAspectFit;
            map.image = [UIImage imageNamed:@"no_chills_yet"];
            /*
            UIWebView *text = [[UIWebView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 300)/2, 280, 300, 100)];
            [cell addSubview:text];
            [text  loadHTMLString:[NSString stringWithFormat:@"<center><p style='font-size:24pt;font-family:HelveticaNeue-Bold'>%@<a style='color:gray;font-family:HelveticaNeue-Light'> wants<br>to chill with you", _nickName] baseURL:nil];
             */
            
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
        return 2;
    else{
//        if (emptyMessages == 0)
//            return _locations.count;
//        else
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


