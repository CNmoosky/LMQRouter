# LMQRouter
> A simple communication router base on URL-Block between modules.    

## How to use


####  模块间使用
```objc
#define URL @"lmq://orderDetail/:orderId"//定义一个全局服务
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
    
```
#### 获取对象

```objc
//注册URL对应的对象
    [LMQRouter registerURLPattern:@"mgj://userView" forObjectBlock:^id(NSDictionary *routerParameters) {
        UIView *userView = [[UIView alloc] init];
        return userView;
    }];
    
    //获取URL对应的对象
    UIView *userView = [LMQRouter objectFromURL:@"mgj://userView" withPrame:nil];
    NSLog(@"%@",userView.description);
```


#### 全局调用

```objc
//注册全局响应
    [LMQRouter registerURLPattern:@"lmq://" forBlock:^(NSDictionary *result) {
        NSLog(@"我是全局响应，对于没有对应注册的lmq://xxx的open都会到这里来");
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
```

