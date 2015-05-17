//
//  HAPaperCollectionViewController.h
//  Paper
//
//  Created by Heberti Almeida on 11/02/14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

@import UIKit;

@interface HAPaperCollectionViewController : UICollectionViewController {
    double latitiude;
    double longitude;
}

- (UICollectionViewController*)nextViewControllerAtPoint:(CGPoint)point;
- (void)dismissPaperCollection;
@property (strong, nonatomic) NSString *nickName;
@property (readwrite) NSInteger friendUserID;
@property (weak, nonatomic) UIImageView *cellStatusView;
@property(nonatomic, strong) NSMutableDictionary *progressViewsDictionary;
@end
