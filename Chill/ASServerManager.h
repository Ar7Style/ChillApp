//
//  ASDataManger.h
//  ChiliFavorite
//
//  Created by MD on 05.01.16.
//  Copyright (c) 2016 MD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface ASServerManager : NSObject

+ (ASServerManager*) sharedManager;

-(void) getJsonImageWithOffset:(NSInteger) offset
                      packName:(NSString *)packName
                         count:(NSInteger) count
                     onSuccess:(void(^)(NSArray* modelArrayImage)) success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void) getJsonImageWithOffsetForOnboarding:(NSInteger) offset
                               numberOfPage: (NSInteger)number
                      packName:(NSString *)packName
                         count:(NSInteger) count
                     onSuccess:(void(^)(NSArray* modelArrayImage)) success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void) postSendSelectedIconId:(NSString*) selectedIconsID
                     onSuccess:(void(^)(NSString* status)) success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

@end
