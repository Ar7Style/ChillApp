//
//  CHLDisplayPhotoViewController.h
//  Chill
//
//  Created by Tareyev Gregory on 11.01.16.
//  Copyright © 2016 Chlil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHLDisplayPhotoViewController : UIViewController {
   // NSArray* json;
    //int i;
}

@property (weak, nonatomic) IBOutlet UIImageView *photoSpace;
@property (strong, nonatomic) NSString* urlOfImage;
//@property (weak, nonatomic) IBOutlet UIImageView *photoSpace;
@property (weak, nonatomic) NSArray *json;
@property int i;

@end
