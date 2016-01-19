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
    [_photoSpace setImageWithURL:[NSURL URLWithString:_urlOfImage]];
    NSLog(@"urlOfImage: %@", _urlOfImage);

}
- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
