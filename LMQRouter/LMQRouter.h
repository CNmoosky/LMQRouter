//
//  LMQRouter.h
//  LMQRouter
//
//  Created by lizhengheng on 2017/7/2.
//  Copyright © 2017 limengqi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LMQRouterBlock)(NSDictionary *result);
typedef id(^LMQRouterObjectBlock)(NSDictionary *result);

@interface LMQRouter : NSObject

+ (void)registerURLPattern:(NSString *)URLPattern forBlock:(LMQRouterBlock)block;

+ (void)deregisterURLPattern:(NSString *)URLPattern;

+ (void)openURL:(NSString *)URL withPrame:(NSDictionary *)prame completion:(LMQRouterBlock)completion;


+ (void)registerURLPattern:(NSString *)URLPattern forObjectBlock:(LMQRouterObjectBlock)block;

+ (id)objectFromURL:(NSString *)URL withPrame:(NSDictionary *)prame;


+ (NSString *)generateURLWithPattern:(NSString *)pattern parameters:(NSArray *)parameters;

@end

