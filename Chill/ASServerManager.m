//
//  ASDataManger.m
//  ChiliFavorite
//
//  Created by MD on 05.01.16.
//  Copyright (c) 2016 MD. All rights reserved.
//

#import "ASServerManager.h"
#import "ASImageModel.h"
#import "FEMMapping.h"
#import "FEMDeserializer.h"
#import "userCache.h"

#import "UIImageView+AFNetworking.h"

@import UIKit;

@interface ASServerManager ()

@property (strong, nonatomic) AFHTTPRequestOperationManager* requestOperationManager;
@property (strong,nonatomic) dispatch_queue_t requestQueue;

@end


@implementation ASServerManager

+ (ASServerManager*) sharedManager {
    static ASServerManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ASServerManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.requestQueue = dispatch_queue_create("iOSDevCourse.requestVk", DISPATCH_QUEUE_PRIORITY_DEFAULT);
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:[NSURL URLWithString:@""]];
        self.requestOperationManager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}

-(void) getJsonImageWithOffset:(NSInteger) offset
                      packName:(NSString *)packName
                         count:(NSInteger) count
                     onSuccess:(void(^)(NSArray* modelArrayImage)) success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];

    
    NSDictionary *parametr = @{@"id_user":[userCache valueForKey:@"id_user"]};

   // X-API-KEY: 76eb29d3ca26fe805545812850e6d75af933214a
   // X-API-TOKEN: 2eea2a10324f35fe022f02   
   
   // @"http://api.iamchill.co/v2/icons/index/id_user/4/name_.."
   // @"http://api.iamchill.co/v2/icons/user/id_user/4"
    
    [self.requestOperationManager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    [self.requestOperationManager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];

    NSString* url = [ NSString stringWithFormat:@"http://api.iamchill.co/v3/icons/index/id_user/%@/name_pack/%@", [userCache valueForKey:@"id_user"], packName];
    [self.requestOperationManager GET:url //@"http://api.iamchill.co/v2/icons/index/id_user/4/name_pack/main"
                           parameters:nil //parametr
                              success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
                                  
                                  NSLog(@"responseObject = %@",responseObject);
                                  
                                  // - Простой парсинг
                                  /*
                                  NSArray*  items  = [responseObject  objectForKey:@"news"];
                                  NSMutableArray* objectsArray = [NSMutableArray array];
                                  
                                  for (NSDictionary* dict in items) {
                                      ASImageModel* img = [[ASImageModel alloc] initWithServerResponse:dict];
                                      [objectsArray addObject:img];
                                  }
                                  success(objectsArray);*/
                                  
                                  
                                   // - Маппинг
                                   if (responseObject){
                                   FEMMapping *objectMapping = [ASImageModel defaultMapping];
                                   NSArray* modelsArray      = [FEMDeserializer collectionFromRepresentation:responseObject[@"response"] mapping:objectMapping];
                                  success(modelsArray);
                                   }
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError* error){
                                  NSLog(@"Error: %@",error);
                                  if (failure) {
                                      failure(error, operation.response.statusCode);
                                  }
                              }];
}

-(void) getJsonImageWithOffsetForOnboarding:(NSInteger) offset
                    numberOfPage: (NSInteger) number
                      packName:(NSString *)packName
                         count:(NSInteger) count
                     onSuccess:(void(^)(NSArray* modelArrayImage)) success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    
    
    NSDictionary *parametr = @{@"id_user":[userCache valueForKey:@"id_user"]};
    
    // X-API-KEY: 76eb29d3ca26fe805545812850e6d75af933214a
    // X-API-TOKEN: 2eea2a10324f35fe022f02
    
    // @"http://api.iamchill.co/v2/icons/index/id_user/4/name_.."
    // @"http://api.iamchill.co/v2/icons/user/id_user/4"
    
    [self.requestOperationManager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    [self.requestOperationManager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    
    NSString* url = [ NSString stringWithFormat:@"http://api.iamchill.co/v3/icons/index/id_user/%@/name_pack/%@", [userCache valueForKey:@"id_user"], packName];
    [self.requestOperationManager GET:url //@"http://api.iamchill.co/v2/icons/index/id_user/4/name_pack/main"
                           parameters:nil //parametr
                              success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
                                  
                                  NSLog(@"responseObject = %@",responseObject);
                                  
                                  // - Простой парсинг
                                  /*
                                   NSArray*  items  = [responseObject  objectForKey:@"news"];
                                   NSMutableArray* objectsArray = [NSMutableArray array];
                                   
                                   for (NSDictionary* dict in items) {
                                   ASImageModel* img = [[ASImageModel alloc] initWithServerResponse:dict];
                                   [objectsArray addObject:img];
                                   }
                                   success(objectsArray);*/
                                  
                                  
                                  // - Маппинг
                                  if (responseObject){
                                      FEMMapping *objectMapping = [ASImageModel defaultMapping];
                                      NSArray* modelsArray      = [FEMDeserializer collectionFromRepresentation:[responseObject[@"response"] valueForKey:[NSString stringWithFormat:@"act%ld",(long)number]] mapping:objectMapping];
                                      success(modelsArray);
                                  }
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError* error){
                                  NSLog(@"Error: %@",error);
                                  if (failure) {
                                      failure(error, operation.response.statusCode);
                                  }
                              }];
}


-(void) postSendSelectedIconId:(NSString*) selectedIconsID
                     onSuccess:(void(^)(NSString* status)) success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode))failure {
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    NSDictionary *parametr = @{@"id_user":[userCache valueForKey:@"id_user"], @"id_icons_user": selectedIconsID};
    
    [self.requestOperationManager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    [self.requestOperationManager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];

    
    [self.requestOperationManager POST:@"http://api.iamchill.co/v2/icons/index"
                            parameters:parametr
                               success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
                                   
                                   NSLog(@"responseObject = %@",responseObject);
                                   success([responseObject objectForKey:@"status"]);
                               
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError* error){
                                   NSLog(@"Error: %@",error);
                                   if (failure) {
                                       failure(error, operation.response.statusCode);
                                   }
                               }];
    
}

@end
