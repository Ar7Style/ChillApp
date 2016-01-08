//
//  ASImageModel.h
//  ChiliFavorite
//
//  Created by MD on 05.01.16.
//  Copyright (c) 2016 MD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FEMMapping.h"

@interface ASImageModel : NSObject

@property (strong, nonatomic) NSString* imageID;
@property (strong, nonatomic) NSString* imageName;
@property (strong, nonatomic) NSString* imageDesc;
@property (strong, nonatomic) NSString* imagePack;


@property (strong, nonatomic) NSString* imageSize42;
@property (strong, nonatomic) NSString* imageSize66;
@property (strong, nonatomic) NSString* imageSize80;
@property (strong, nonatomic) NSString* imageSize214;
@property (strong, nonatomic) NSString* imageSize272;
@property (strong, nonatomic) NSString* bytes;

- (instancetype) initWithServerResponse:(NSDictionary*) responseObject;
+ (FEMMapping *)defaultMapping;

@end
