//
//  LMQRouterTool.h
//  LMQRouter
//
//  Created by lizhengheng on 2017/7/2.
//  Copyright © 2017 limengqi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LMQRouterTool : NSObject

+ (NSArray*)pathComponentsFromURL:(NSString*)URL;

+ (NSMutableDictionary *)extractParametersFromURL:(NSString *)url withRoutes:(NSMutableDictionary *)routes matchExactly:(BOOL)exactly;

+ (NSString *)generateURLWithPattern:(NSString *)pattern parameters:(NSArray *)parameters;

@end

extern NSString * const LMQ_ROUTER_BLOCK_DATA_KEY;
extern NSString * const LMQ_ROUTER_PLACEHOLDER_CHARACTER;

extern NSString *const LMQRouterParameterBlockKey;
extern NSString *const LMQRouterParameterURLKey;
extern NSString *const LMQRouterParameterCompletionBlockKey;
extern NSString *const LMQRouterParameterPrameKey;
