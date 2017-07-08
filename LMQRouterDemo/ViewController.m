//
//  ViewController.m
//  LMQRouterDemo
//
//  Created by lizhengheng on 2017/7/2.
//  Copyright © 2017 limengqi. All rights reserved.
//

#import "ViewController.h"
#import "LMQRouter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //注册全局响应
    [LMQRouter registerURLPattern:@"lmq://" forBlock:^(NSDictionary *result) {
        NSLog(@"我是全局响应，没有对应注册的open都会到这里来");
        if (result) {
            NSLog(@"%@",result);
            NSLog(@"%@\n",result[LMQRouterParameterURLKey]);
            NSLog(@"%@\n",result[LMQRouterParameterPrameKey]);
            LMQRouterBlock block = result[LMQRouterParameterCompletionBlockKey];
            if (block) {
                block(nil);
            }
        }
    }];
    
    //在提供服务的模块中注册服务
    [LMQRouter registerURLPattern:@"lmq://hahaha" forBlock:^(NSDictionary *result) {
        NSLog(@"你好啊");
        if (result) {
            NSLog(@"%@",result);
            NSLog(@"%@\n",result[LMQRouterParameterURLKey]);
            NSLog(@"%@\n",result[LMQRouterParameterPrameKey]);
            LMQRouterBlock block = result[LMQRouterParameterCompletionBlockKey];
            if (block) {
                block(nil);
            }
        }
    }];
    
    //在其他模块调用服务的同时进行传参
    [LMQRouter openURL:@"lmq://hahaha" withPrame:@{@"ss":@"sss"} completion:^(NSDictionary *result) {
        NSLog(@"Hello World!");
        if (result) {
            NSLog(@"%@",result);
        }
    }];
    
    
    //通过URL传参
    [LMQRouter registerURLPattern:@"lmq://key/:userId" forBlock:^(NSDictionary *result) {
        NSLog(@"你好啊");
        if (result) {
            NSLog(@"%@",result);
            NSLog(@"%@\n",result[LMQRouterParameterURLKey]);
            
            
            NSDictionary *prame = result[LMQRouterParameterPrameKey];
            if (prame) {
                NSLog(@"prame--%@\n",prame);
                //模拟网络请求
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    LMQRouterBlock block = result[LMQRouterParameterCompletionBlockKey];
                    if (block) {
                        block(@{@"userId":prame[@"userId"],@"headPhoto":@"http:xxxx.jpg",@"nickName":@"doge"});
                    }
                });
            }
            
        }
    }];
    
    
    //调用
    [LMQRouter openURL:@"lmq://key/3" withPrame:nil completion:^(NSDictionary *result) {
        NSLog(@"Hello World!");
        if (result) {
            NSLog(@"%@",result);
        }
    }];
    
    
    //模块间使用方式
#define URL @"lmq://orderDetail/:orderId"//一个全局服务的定义
    //
    [LMQRouter registerURLPattern:URL forBlock:^(NSDictionary *result) {
        NSLog(@"开始查找订单喽");
        if (result) {

            NSDictionary *prame = result[LMQRouterParameterPrameKey];
            if (prame) {
                NSLog(@"prame--%@\n",prame);
                //模拟网络请求
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    LMQRouterBlock block = result[LMQRouterParameterCompletionBlockKey];
                    if (block) {
                        block(@{@"OrderId":prame[@"orderId"],@"image":@"http:xxxx.jpg",@"price":@"200"});
                    }
                });
            }
            
        }
    }];
    
    //此调用可在其他模块之中
    [LMQRouter openURL:[LMQRouter generateURLWithPattern:URL parameters:@[@3344]] withPrame:nil completion:^(NSDictionary *result) {
        NSLog(@"拿到订单详细");
        NSLog(@"%@",result);
    }];
    
    
    //注册URL对应的对象
    [LMQRouter registerURLPattern:@"lmq://userView" forObjectBlock:^id(NSDictionary *routerParameters) {
        UIView *userView = [[UIView alloc] init];
        return userView;
    }];
    
    //获取URL对应的对象
    UIView *userView = [LMQRouter objectFromURL:@"lmq://userView" withPrame:nil];
    NSLog(@"%@",userView.description);
}


@end
