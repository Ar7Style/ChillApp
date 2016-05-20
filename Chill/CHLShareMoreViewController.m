//
//  CHLShareMoreViewController.m
//  Chill
//
//  Created by Ivan Grachev on 2/19/16.
//  Copyright © 2016 Chlil. All rights reserved.
//

#import "CHLShareMoreViewController.h"

#import "ASImageCell.h"
#import "ASImageModel.h"
#import "ANHelperFunctions.h"
#import "ASServerManager.h"
#import "SCLAlertView.h"

#import "RKDropdownAlert.h"

#import "UIImage+imageWithColor.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import "Reachability.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "UserCache.h"
#import "UIColor+ChillColors.h"
#import "LLACircularProgressView.h"
#import "HAPaperCollectionViewController.h"

@interface CHLShareMoreViewController () <UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *characktersCounterLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *arrayAllIcon;
@property (assign, nonatomic) BOOL loadingData;
@property(nonatomic, strong) NSString *text;

@end

NSMutableData *mutData;

@implementation CHLShareMoreViewController

- (IBAction)textBeenEdited:(id)sender {
    self.characktersCounterLabel.text = [NSString stringWithFormat:@"%ld", (long)(10 - self.hashtagTextField.text.length)];
    if ((long)(10 - self.hashtagTextField.text.length) <= 0) {
        self.characktersCounterLabel.textColor = [UIColor redColor];
    }
    else {
        self.characktersCounterLabel.textColor = [UIColor chillMintColor];
    }
}

- (void)viewDidLoad {
    [self.navigationController.navigationBar setTintColor:[UIColor chillMintColor]];
    self.characktersCounterLabel.textColor = [UIColor chillMintColor];
    [self setupCollectionView];
    self.arrayAllIcon = [NSMutableArray array];
    if ([self isInternetConnection]) {
        ANDispatchBlockToBackgroundQueue(^{
            [self getIconsFromServer];
        });
    }
    self.hashtagTextField.text = self.tempText;
    
    [super viewDidLoad];
    [self.activityIndicatorView startAnimating];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];

}

-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer {
    //[self.emailField resignFirstResponder];
    [self.hashtagTextField resignFirstResponder];
}

-(void)dismissKeyboard {
    [_hashtagTextField resignFirstResponder];
   // [self.view removeGestureRecognizer:tap];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        if (!self.loadingData){
            self.loadingData = YES;
        }
    }
}

#pragma mark - Server

-(void) getIconsFromServer {
    [[ASServerManager sharedManager] getJsonImageWithOffset:[self.arrayAllIcon count]
                                                   packName:@"main"
                                                      count:20
                                                  onSuccess:^(NSArray *modelArrayImage) {
                                                      if ([modelArrayImage count] > 0) {
                                                          [self.arrayAllIcon addObjectsFromArray:modelArrayImage];
                                                          
                                                          ANDispatchBlockToMainQueue(^{
                                                              [self.collectionView reloadData];
                                                              self.loadingData = NO;
                                                          });
                                                      }
                                                  } onFailure:^(NSError *error, NSInteger statusCode) {
                                                      
                                                  }];
}

#pragma mark - UICollectionViewDataSource

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.arrayAllIcon count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if ([UIScreen mainScreen].scale >= 2.9)
        {
            return CGSizeMake(90, 90);
        }
        else {
            if ([[UIScreen mainScreen] bounds].size.height <= 568) {
                return CGSizeMake(65, 75);
            }
            return CGSizeMake(68, 75);
        }
    }
    return CGSizeMake(65, 75);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"ASImageCell";
    
    ASImageCell*  cell = (ASImageCell*) [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    ASImageModel* model = self.arrayAllIcon[indexPath.row];
    NSString *iconName = model.imageName;
    cell.backgroundColor = [UIColor whiteColor];
    UIImage *cachedImage = [self fetchImageWithName:iconName];
    if (cachedImage != nil) {
        cell.imgView.image = [cachedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [cell.imgView setTintColor:[UIColor chillMintColor]];
        self.activityIndicatorView.hidden = YES;
    }
    else {
        __weak UIImageView *weakImageView = cell.imgView;
        __weak CHLShareMoreViewController *weakSelf = self;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:model.imageSize66]];
        [weakImageView setImageWithURLRequest:request
                             placeholderImage:[UIImage imageNamed:@"iconPlaceholder"]
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                          [weakSelf saveImage:image withName:iconName];
                                          weakSelf.activityIndicatorView.hidden = YES;
                                          weakImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                                          [weakImageView setTintColor:[UIColor chillMintColor]];
                                          
                                      } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                          NSLog(@"Request failed with error: %@", error);
                                      }];
    }
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ASImageModel *model = self.arrayAllIcon[indexPath.row];
    [self shareIconWithType:model.imageName];
}


#pragma mark - Other

-(BOOL) isInternetConnection {
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            SCLAlertView* alert = [[SCLAlertView alloc] init];
//            [alert showError:self.parentViewController title:@"Oups" subTitle:@"Please, check your internet connection" closeButtonTitle:@"OK" duration:0.0f];
            [RKDropdownAlert title:@"No internet" message:@"" backgroundColor:[UIColor colorWithRed:0.66 green:0.66 blue:0.66 alpha:0.96] textColor:[UIColor whiteColor] time:4];
        });
        return NO;
    }
    return YES;
}

-(void) setupCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    layout.minimumInteritemSpacing = 1.0;
    layout.minimumLineSpacing = 1.0;
    layout.sectionInset = UIEdgeInsetsMake(1, 1, 1, 1);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView.collectionViewLayout = layout;
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView setShowsVerticalScrollIndicator:NO];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    self.collectionView.scrollEnabled = YES;
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
}

-(void)showError:(NSString *)message {
//    SCLAlertView* alert = [[SCLAlertView alloc] init];
//    [alert showError:self title:@"Oups" subTitle:message closeButtonTitle:@"OK" duration:0.0f];
    [RKDropdownAlert title:@"No internet" message:@"" backgroundColor:[UIColor colorWithRed:0.66 green:0.66 blue:0.66 alpha:0.96] textColor:[UIColor whiteColor] time:4];
}

- (void)shareIconWithType:(NSString *)iconType
{
    NSUserDefaults *cacheSpec = [NSUserDefaults standardUserDefaults];
    if ([cacheSpec boolForKey:@"gotToShareFromHA"]) {
        [cacheSpec setBool:NO forKey:@"gotToShareFromHA"];
        HAPaperCollectionViewController *presentingVC = (HAPaperCollectionViewController *)self.presentingViewController;
        [self dismissViewControllerAnimated:YES completion:^{
            [presentingVC dismissPaperCollection:nil];
        }];
    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    if ([self.characktersCounterLabel.text integerValue] < 0) {
        [self showError:@"You can only send 10 symbols"];
        self.hashtagTextField.text = @"";
        self.characktersCounterLabel.textColor = [UIColor chillMintColor];
        self.characktersCounterLabel.text = [NSString stringWithFormat:@"%d", 10];
        
    }
    else {
        NSMutableURLRequest *requestForNotifications = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.iamchill.co/v2/notifications/message"]];
        
        [requestForNotifications setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
        [requestForNotifications setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
        [requestForNotifications setHTTPMethod:@"POST"];
        
        NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
        
        [self.hashtagTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.text = self.hashtagTextField.text;
        NSString *postStringForNotifications = [NSString stringWithFormat:@"id_contact=%ld&id_user=%@&content=%@&type=icon&text=%@", (long)_userIdTo, [userCache valueForKey:@"id_user"], iconType, self.hashtagTextField.text];
        
        [requestForNotifications setHTTPBody:[postStringForNotifications dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLConnection *connectionForNotifications = [[NSURLConnection alloc] initWithRequest:requestForNotifications delegate:self];
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.iamchill.co/v2/messages/index"]];
        [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
        [request setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
        
        [request setHTTPMethod:@"POST"];
        
        
        [self.hashtagTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.text = self.hashtagTextField.text;
        NSString *postString = [NSString stringWithFormat:@"id_contact=%ld&id_user=%@&content=%@&type=icon&text=%@", (long)_userIdTo, [userCache valueForKey:@"id_user"], iconType, self.hashtagTextField.text];
        NSLog(@"POST STRING: %@", postString);
        
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (connection) {
            mutData = [NSMutableData data];
        }
        
        LLACircularProgressView *progressView = [[LLACircularProgressView alloc] initProgressViewWithDummyProgress:0.0 cellStatusView:self.cellStatusView];
        [self.progressViewsDictionary setObject:progressView forKey:[NSNumber numberWithInteger:self.userIdTo]];
    }
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    float currentProgress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    LLACircularProgressView *currentProgressView = [self.progressViewsDictionary objectForKey:[NSNumber numberWithInteger:self.userIdTo]];
    [currentProgressView setProgress:(currentProgress > currentProgressView.progress ? currentProgress : currentProgressView.progress) animated:YES];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [mutData setLength:0];
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mutData appendData:data];
}

#pragma mark - Icons caching

- (void)saveImage:(UIImage *)image withName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:name];
    [UIImagePNGRepresentation(image) writeToFile:savedImagePath atomically:NO];
}

- (UIImage *)fetchImageWithName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:name];
    NSData *pngData = [NSData dataWithContentsOfFile:savedImagePath];
    return [UIImage imageWithData:pngData scale:2.0];
}

@end
