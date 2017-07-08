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

+ (NSString *)generateURLWithPattern:(NSString *)pattern parameters:(NSArray *)parameters;

+ (BOOL)checkIfContainsSpecialCharacter:(NSString *)checkedString;

@end

extern NSString * const URLSpecialCharacters;
extern NSString * const LMQ_ROUTER_PLACEHOLDER_CHARACTER;
