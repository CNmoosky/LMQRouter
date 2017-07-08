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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [LMQRouter registerURLPattern:@"lmq://hahaha" forBlock:^(NSDictionary *result) {
        NSLog(@"你好啊");
        if (result) {
            NSLog(@"%@",result);
            NSLog(@"%@\n",result[LMQRouterParameterURLKey]);
            NSLog(@"%@\n",result[LMQRouterParameterPrameKey]);
            NSLog(@"%@\n",result[LMQRouterParameterCompletionBlockKey]);
        }
    }];
    
    [LMQRouter openURL:@"lmq://hahaha" withPrame:@{@"ss":@"sss"} completion:^(NSDictionary *result) {
        NSLog(@"Hello World!");
        if (result) {
            NSLog(@"%@",result);
        }
    }];
}


@end
