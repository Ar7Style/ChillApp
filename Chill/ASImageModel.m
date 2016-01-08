
//
//  ASImageModel.m
//  ChiliFavorite
//
//  Created by MD on 05.01.16.
//  Copyright (c) 2016 MD. All rights reserved.
//

#import "ASImageModel.h"

@implementation ASImageModel

-(instancetype) initWithServerResponse:(NSDictionary*) responseObject {
    
    self = [super init];
    if (self) {

        
         self.imageID = [responseObject objectForKey:@"id"];
         self.imageName = [responseObject objectForKey:@"name"];
         self.imageDesc = [responseObject objectForKey:@"description"];
         self.imagePack = [responseObject objectForKey:@"pack"];
        
        
         self.imageSize42 = [responseObject objectForKey:@"size42"];
         self.imageSize66 = [responseObject objectForKey:@"size66"];
         self.imageSize80 = [responseObject objectForKey:@"size80"];
         self.imageSize214 = [responseObject objectForKey:@"size214"];
         self.imageSize272 = [responseObject objectForKey:@"size272"];
         self.bytes        = [responseObject objectForKey:@"bytes"];

    }
    return self;
}

+ (FEMMapping *)defaultMapping
{
    FEMMapping *mapping = [[FEMMapping alloc] initWithObjectClass:[ASImageModel class]];
  

    [mapping addAttributesFromDictionary:@{@"imageID"    :@"id",
                                           @"imageName"  :@"name",
                                           @"imageDesc":@"description",
                                           @"imagePack"  :@"pack",
                                           
                                           @"imageSize42"  :@"size42",
                                           @"imageSize66"  :@"size66",
                                           @"imageSize80"  :@"size80",
                                           @"imageSize214" :@"size214",
                                           @"imageSize272" :@"size272",
                                           @"bytes"    :@"bytes"}];

    return mapping;
}


@end
