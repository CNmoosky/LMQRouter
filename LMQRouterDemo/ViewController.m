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
    }];
    
    [LMQRouter openURL:@"lmq://hahaha" withPrame:@{@"ss":@"sss"} completion:nil];
}


@end
