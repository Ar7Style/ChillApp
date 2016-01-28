//
//  ASFirstCVC.m
//  ChiliFavorite
//
//  Created by MD on 05.01.16.
//  Copyright (c) 2016 MD. All rights reserved.
//

#import "ASFirstCVC.h"

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

@interface ASFirstCVC () <UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate> {
    NSInteger selectedIconsNumber;
    NSArray* arrayOfSelectedIcons;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray*  arrayFavoriteIcon;
@property (strong, nonatomic) NSMutableArray*  arraySelectedIcon;
@property (strong, nonatomic) NSMutableArray*  arraySelectedIconID;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (assign, nonatomic) BOOL loadingData;
@end

@implementation ASFirstCVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCollectionView];
   // arrayOfSelectedIcons =[[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedIcons"] componentsSeparatedByString:@"-"];
    //selectedIconsNumber=arrayOfSelectedIcons.count;
    NSLog(@"arrayOfSelectedIcons count: %lu", (unsigned long)arrayOfSelectedIcons.count);
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"selectedIcons"]);
    if( selectedIconsNumber == 6 ) _doneButton.userInteractionEnabled = YES;
    
    self.navigationController.navigationBar.barTintColor = [UIColor yellowColor];

    self.arraySelectedIcon   = [NSMutableArray array];
    self.arrayFavoriteIcon   = [NSMutableArray array];
    
    self.arraySelectedIconID = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"arraySelectedIconID"]];
    
    if (!self.arraySelectedIconID) {
        self.arraySelectedIconID  = [NSMutableArray array];
        
    }
    if ([self isInternetConnection]) {
        ANDispatchBlockToBackgroundQueue(^{
            [self getFavIconsFromServer];
        });
    }
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
    return CGSizeMake(80, 80);
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
                                      weakImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                                      
                                      if (self.arraySelectedIconID.count>0){
                                          
                                          if ([self.arraySelectedIconID containsObject:iconModel.imageID]){
                                              [weakImageView setTintColor:[UIColor colorWithRed:(235/255.0) green:(216/255.0) blue:(48/255.0) alpha:1]];
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
    ASImageModel* model = self.arrayFavoriteIcon[indexPath.row];
    
    if ([self.arraySelectedIconID count]<6) {
        
        if ([self.arraySelectedIconID containsObject:model.imageID]) {
            [self.arraySelectedIconID removeObject:model.imageID];
            cell.imgView.image = [cell.imgView.image imageWithColor:[UIColor colorWithRed:(216/255.0) green:(216/255.0) blue:(216/255.0) alpha:1]];
        } else {
            [self.arraySelectedIconID addObject:model.imageID];
            cell.imgView.image = [cell.imgView.image imageWithColor:[UIColor colorWithRed:(235/255.0) green:(216/255.0) blue:(48/255.0) alpha:1]];
        }
    } else {
        if ([self.arraySelectedIconID containsObject:model.imageID]) {
            [self.arraySelectedIconID removeObject:model.imageID];
            cell.imgView.image = [cell.imgView.image imageWithColor:[UIColor colorWithRed:(216/255.0) green:(216/255.0) blue:(216/255.0) alpha:1]];
        }
    }

//    ASImageCell *cell = (ASImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    ASImageModel* model = self.arrayFavoriteIcon[indexPath.row];
//    
//    //[self.arraySelectedIconID addObjectsFromArray:arrayOfSelectedIcons];
//    
//    if ([self.arraySelectedIcon count]<6) {
//       
//        if ([self.arraySelectedIcon containsObject:indexPath]) {
//            [self.arraySelectedIcon removeObject:indexPath];
//            [self.arraySelectedIconID removeObject:model.imageID];
//            
//            cell.imgView.image = [cell.imgView.image imageWithColor:[UIColor colorWithRed:(216/255.0) green:(216/255.0) blue:(216/255.0) alpha:1]];
//            selectedIconsNumber--;
//        }else {
//            [self.arraySelectedIcon addObject:indexPath];
//            [self.arraySelectedIconID addObject:model.imageID];
//            
//            cell.imgView.image = [cell.imgView.image imageWithColor:[UIColor colorWithRed:(235/255.0) green:(216/255.0) blue:(48/255.0) alpha:1]];
//            if (selectedIconsNumber<6) selectedIconsNumber++;
//            
//        }
//    } else {
//        if ([self.arraySelectedIcon containsObject:indexPath]) {
//            [self.arraySelectedIcon removeObject:indexPath];
//            [self.arraySelectedIconID removeObject:model.imageID];
//            
//            cell.imgView.image = [cell.imgView.image imageWithColor:[UIColor colorWithRed:(216/255.0) green:(216/255.0) blue:(216/255.0) alpha:1]];
//            selectedIconsNumber--;
//        }
//    }
//    if (selectedIconsNumber<6) _doneButton.userInteractionEnabled = NO;
//    else _doneButton.userInteractionEnabled = YES;
//    NSLog(@"selectedIconsNumber: %ld", (long)selectedIconsNumber);
}


#pragma mark - Other

-(BOOL) isInternetConnection {
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            SCLAlertView* alert = [[SCLAlertView alloc] init];
            [alert showError:self.parentViewController title:@"Ошибка" subTitle:@"Соедиения с интернетом" closeButtonTitle:@"OK" duration:0.0f];
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

#pragma mark - Action


- (IBAction)doneAction:(id)sender {
   
    if ([self.arraySelectedIconID count]<6) {
        SCLAlertView* alert = [[SCLAlertView alloc] init];
        [alert showError:self.parentViewController title:@"Error" subTitle:@"Selected 6 icons!" closeButtonTitle:@"OK" duration:0.0f];
        return;
    }
    
    NSString* str = [self.arraySelectedIconID componentsJoinedByString:@"-"];
    
    [[ASServerManager sharedManager] postSendSelectedIconId:str onSuccess:^(NSString *status) {
        
        
        [[NSUserDefaults standardUserDefaults] setObject:self.arraySelectedIconID forKey:@"arraySelectedIconID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        SCLAlertView* alert = [[SCLAlertView alloc] init];
        if ([status isEqualToString:@"success"]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [alert showError:self.parentViewController title:@"Error" subTitle:@"Icons not sending" closeButtonTitle:@"OK" duration:0.0f];
        }
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];

}
@end
