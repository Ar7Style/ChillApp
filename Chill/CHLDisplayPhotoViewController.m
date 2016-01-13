//
//  CHLDisplayPhotoViewController.m
//  Chill
//
//  Created by Tareyev Gregory on 11.01.16.
//  Copyright © 2016 Chlil. All rights reserved.
//

#import "CHLDisplayPhotoViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIColor+ChillColors.h"


@interface CHLDisplayPhotoViewController () {
   
}


@end

@implementation CHLDisplayPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"PhotoDisplayViewController");
    self.view.backgroundColor = [UIColor blackColor];
    _photoSpace.contentMode = UIViewContentModeScaleAspectFill;
    [_photoSpace setImageWithURL:[NSURL URLWithString:[_json[_i] valueForKey:@"content"]]];
    
//    UIButton* closeButton = [[UIButton alloc]init];
//    
//    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
//    {
//        if ([[UIScreen mainScreen] bounds].size.height <= 568) // <= iphone 5
//        {
//            closeButton.frame = CGRectMake(232, 35, 100, 30);
//            [closeButton setTitle:@"Close" forState:UIControlStateNormal];
//            [closeButton setTitleColor:[UIColor chillMintColor] forState:UIControlStateNormal];
//            [closeButton addTarget:self action:@selector(dismissController:) forControlEvents:UIControlEventTouchUpInside];
//            [self.view addSubview:closeButton];
//        }
//        
//        else if ([UIScreen mainScreen].scale >= 2.9) // >= iphone 6 plus
//        {
//            closeButton.frame = CGRectMake(337, 35, 100, 30);
//            [closeButton setTitle:@"Close" forState:UIControlStateNormal];
//            [closeButton setTitleColor:[UIColor chillMintColor] forState:UIControlStateNormal];
//            [closeButton addTarget:self action:@selector(dismissController:) forControlEvents:UIControlEventTouchUpInside];
//            [self.view addSubview:closeButton];
//        }
//        
//        else { // iphone 6
//            closeButton.frame = CGRectMake(289, 35, 100, 30);
//            [closeButton setTitle:@"Close" forState:UIControlStateNormal];
//            [closeButton setTitleColor:[UIColor chillMintColor] forState:UIControlStateNormal];
//            [closeButton addTarget:self action:@selector(dismissController:) forControlEvents:UIControlEventTouchUpInside];
//            [self.view addSubview:closeButton];
//            
//        }
//    }

}
- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}

//-(void) dismissController:(id)sender {
//    [self dismissViewControllerAnimated:NO completion:nil];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
