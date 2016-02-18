//
//  CHLOnboardingEndVC.m
//  Chill
//
//  Created by Ivan Grachev on 2/16/16.
//  Copyright © 2016 Chlil. All rights reserved.
//

#import "CHLOnboardingEndVC.h"

#import "ASImageCell.h"
#import "ASImageModel.h"
#import "ANHelperFunctions.h"
#import "ASServerManager.h"
#import "SCLAlertView.h"
#import "UIImage+imageWithColor.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import "Reachability.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "UserCache.h"
#import "UIColor+ChillColors.h"

@interface CHLOnboardingEndVC () <UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate> {
    NSInteger selectedIconsNumber;
    NSArray* arrayOfSelectedIcons;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray*  arraySelectedIconID;
@property (strong, nonatomic) NSMutableArray*  arrayAllIcon;
@property (strong, nonatomic) NSMutableArray*  arraySelectedIcon;
@property (assign, nonatomic) BOOL loadingData;

@end

@implementation CHLOnboardingEndVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCollectionView];
    
    self.arraySelectedIcon   = [NSMutableArray array];
    self.arrayAllIcon   = [NSMutableArray array];
    
    if (!self.arraySelectedIconID) {
        self.arraySelectedIconID  = [NSMutableArray array];
        
    }
    if ([self isInternetConnection]) {
        ANDispatchBlockToBackgroundQueue(^{
            [self getIconsFromServer];
        });
    }
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

-(void) getIconsFromServer{
    
    [[ASServerManager sharedManager] getJsonImageWithOffset:[self.arrayAllIcon count]
                                                   packName:@"all"
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
            return CGSizeMake(100, 100);
        }
        else {
            return CGSizeMake(70, 70);
        }
    }
    return CGSizeMake(70, 70);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"ASImageCell";
    
    ASImageCell*  cell = (ASImageCell*) [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    ASImageModel* model = self.arrayAllIcon[indexPath.row];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    __weak UIImageView *weakImageView = cell.imgView;
    __weak NSIndexPath *weakIndexPath = indexPath;
    __weak ASImageModel *iconModel = model;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:model.imageSize66]];
    [weakImageView setImageWithURLRequest:request
                         placeholderImage:[UIImage imageNamed:@"W2HfHxEVad8"]
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      
                                      weakImageView.image = image;
                                      weakImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                                      
                                      if (self.arraySelectedIconID.count > 0){
                                          
                                          if ([self.arraySelectedIconID containsObject:iconModel.imageID]){
                                              [weakImageView setTintColor:[UIColor chillMintColor]];
                                          } else {
                                              [weakImageView setTintColor:[UIColor colorWithRed:(216/255.0) green:(216/255.0) blue:(216/255.0) alpha:1]];
                                          }
                                      } else {
                                          [weakImageView setTintColor:[UIColor colorWithRed:(216/255.0) green:(216/255.0) blue:(216/255.0) alpha:1]];
                                      }
                                      
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      NSLog(@"Request failed with error: %@", error);
                                  }];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ASImageCell *cell = (ASImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
    ASImageModel *model = self.arrayAllIcon[indexPath.row];
    if ([self.arraySelectedIconID containsObject:model.imageID]) {
        [self.arraySelectedIconID removeObject:model.imageID];
        cell.imgView.image = [cell.imgView.image imageWithColor:[UIColor colorWithRed:(216/255.0) green:(216/255.0) blue:(216/255.0) alpha:1]];
    } else {
        [self.arraySelectedIconID addObject:model.imageID];
        cell.imgView.image = [cell.imgView.image imageWithColor:[UIColor chillMintColor]];
    }
    if ([self.arraySelectedIconID count] == 6) {
        [self finishOnboarding];
    }
}


#pragma mark - Other

-(BOOL) isInternetConnection {
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            SCLAlertView* alert = [[SCLAlertView alloc] init];
            [alert showError:self.parentViewController title:@"Oups" subTitle:@"Please, check your internet connection" closeButtonTitle:@"OK" duration:0.0f];
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
    SCLAlertView* alert = [[SCLAlertView alloc] init];
    [alert showError:self title:@"Oups" subTitle:message closeButtonTitle:@"OK" duration:0.0f];
}

- (void)finishOnboarding
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
    NSString* str = [self.arraySelectedIconID componentsJoinedByString:@"-"];
    [[ASServerManager sharedManager] postSendSelectedIconId:str onSuccess:^(NSString *status) {}
                                                  onFailure:^(NSError *error, NSInteger statusCode) {}];
}

@end
