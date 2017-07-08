//
//  LMQRouter.h
//  LMQRouter
//
//  Created by lizhengheng on 2017/7/2.
//  Copyright © 2017 limengqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMQRouterConst.h"

typedef void(^LMQRouterBlock)(NSDictionary *result);
typedef id(^LMQRouterObjectBlock)(NSDictionary *result);

@interface LMQRouter : NSObject

/**
 *  注册URLPattern对应的block，在block中可以做各种操作
 *
 *  @param URLPattern 例子：lmq://path/:userId
 *  @param block    该 block 会传一个字典，包含了注册的 URL 中对应的变量。如果注册的URL是lmq://path/:userId 那么，就会传一个 @{@"userId": 4}
 */
+ (void)registerURLPattern:(NSString *)URLPattern forBlock:(LMQRouterBlock)block;

/**
 注册URLPattern对应的可返回值的block，在block中可以做各种操作
 
 @param URLPattern 例子：lmq://path/:userId
 @param block 该 block 会传一个字典，包含了注册的 URL 中对应的变量。
 */
+ (void)registerURLPattern:(NSString *)URLPattern forObjectBlock:(LMQRouterObjectBlock)block;

/**
 取消注册URLPattern

 @param URLPattern URLPattern
 */
+ (void)deregisterURLPattern:(NSString *)URLPattern;



/**
 *  打开此 URL，带上参数，同时当操作完成时，执行额外的代码
 *
 *  @param URL 例如 lmq://path/4
 *  @param prame 附加参数
 *  @param completion URL 处理完成后的 callback，完成跟具体的业务相关
 */
+ (void)openURL:(NSString *)URL withPrame:(NSDictionary *)prame completion:(LMQRouterBlock)completion;




/**
 * 获取URL对应的返回值
 *
 *  @param URL 带 Scheme，如 lmq://userview
 *  @param prame 参数
 */

+ (id)objectFromURL:(NSString *)URL withPrame:(NSDictionary *)prame;


/**
 拼接URL

 @param pattern 注册时的原始URL
 @param parameters 调用时的参数值传递
 @return 返回完整调用URL
 */
+ (NSString *)generateURLWithPattern:(NSString *)pattern parameters:(NSArray *)parameters;

@end

