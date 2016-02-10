//
//  CHLAdditionalViewController.m
//  Chill
//
//  Created by Tareyev Gregory on 08.02.16.
//  Copyright © 2016 Chlil. All rights reserved.
//

#import "CHLAdditionalViewController.h"

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

@interface CHLAdditionalViewController () <UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (assign, nonatomic) BOOL loadingData;

@property (strong, nonatomic) NSMutableArray*  arrayFavoriteIcon;


@end

@implementation CHLAdditionalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCollectionView];

    self.arrayFavoriteIcon = [NSMutableArray array];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Типо если прокручиваем вниз постепенно подгружаем, но в нашем случае загружаем все сразу
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        if (!self.loadingData){
            self.loadingData = YES;
            //[self getFavIconsFromServer];
        }
    }
}



#pragma mark - Server

-(void) getFavIconsFromServer{
    
    [[ASServerManager sharedManager] getJsonImageWithOffset:[self.arrayFavoriteIcon count]
                                                      count:20
                                                  onSuccess:^(NSArray *modelArrayImage) {
                                                      if ([modelArrayImage count] > 0) {
                                                          [self.arrayFavoriteIcon addObjectsFromArray:modelArrayImage];
                                                          
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
    return [self.arrayFavoriteIcon count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if ([UIScreen mainScreen].scale >= 2.9) // >= iphone 6 plus
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
    ASImageModel* model = self.arrayFavoriteIcon[indexPath.row];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    __weak UIImageView *weakImageView = cell.imgView;
    __weak NSIndexPath *weakIndexPath = indexPath;
    __weak ASImageModel *iconModel     = model;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:model.imageSize66]];
    [weakImageView setImageWithURLRequest:request
                         placeholderImage:[UIImage imageNamed:@"W2HfHxEVad8"]
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      
                                      weakImageView.image = image;
                                      
                                      
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      NSLog(@"Request failed with error: %@", error);
                                  }];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ASImageCell *cell = (ASImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
    ASImageModel* model = self.arrayFavoriteIcon[indexPath.row];
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

-(void) setupCollectionView {
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
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
    //[self.collectionView registerClass:[ASImageCell class] forCellWithReuseIdentifier:@"ASImageCell"];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
}

-(void)showError:(NSString *)message {
    SCLAlertView* alert = [[SCLAlertView alloc] init];
    
    [alert showError:self title:@"Error" subTitle:message closeButtonTitle:@"OK" duration:0.0f];
}

#pragma mark - Action


- (IBAction)doneAction:(id)sender {

   [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
