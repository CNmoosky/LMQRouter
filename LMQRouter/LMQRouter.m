//
//  LMQRouter.m
//  LMQRouter
//
//  Created by lizhengheng on 2017/7/2.
//  Copyright © 2017 limengqi. All rights reserved.
//

#import "LMQRouter.h"
#import "LMQRouterTool.h"

static NSString * const LMQ_ROUTER_BLOCK_DATA_KEY = @"^";
static NSString *const LMQRouterParameterBlockKey = @"block";

@interface LMQRouter ()

@property(nonatomic,strong)NSMutableDictionary *routes;

@end

@implementation LMQRouter

+ (instancetype)sharedInstance
{
    static LMQRouter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - open API

+ (void)registerURLPattern:(NSString *)URLPattern forBlock:(LMQRouterBlock)block
{
    [[self sharedInstance] addURLPattern:URLPattern andBlock:block];
}

+ (void)deregisterURLPattern:(NSString *)URLPattern
{
    [[self sharedInstance] removeURLPattern:URLPattern];
}

+ (void)openURL:(NSString *)URL withPrame:(NSDictionary *)prame completion:(LMQRouterBlock)completion
{
    LMQRouter *router = [LMQRouter sharedInstance];
    URL = [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *parameters = [self extractParametersFromURL:URL withRoutes:router.routes matchExactly:NO];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, NSString *obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            parameters[key] = [obj stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }];
    
    if (parameters) {
        LMQRouterBlock block = parameters[LMQRouterParameterBlockKey];
        if (completion) {
            parameters[LMQRouterParameterCompletionBlockKey] = completion;
        }
        if (prame) {
            parameters[LMQRouterParameterPrameKey] = prame;
        }
        if (block) {
            [parameters removeObjectForKey:LMQRouterParameterBlockKey];
            block(parameters);
        }
    }
}


+ (void)registerURLPattern:(NSString *)URLPattern forObjectBlock:(LMQRouterObjectBlock)block
{
    [[self sharedInstance] addURLPattern:URLPattern andObjectBlock:block];
}

+ (id)objectFromURL:(NSString *)URL withPrame:(NSDictionary *)prame
{
    LMQRouter *router = [LMQRouter sharedInstance];
    
    URL = [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *parameters = [self extractParametersFromURL:URL withRoutes:router.routes matchExactly:NO];
    LMQRouterObjectBlock block = parameters[LMQRouterParameterBlockKey];
    
    if (block) {
        if (prame) {
            parameters[LMQRouterParameterPrameKey] = prame;
        }
        [parameters removeObjectForKey:LMQRouterParameterBlockKey];
        return block(parameters);
    }
    return nil;
}


#pragma mark - add

- (void)addURLPattern:(NSString *)URLPattern andBlock:(LMQRouterBlock)block
{
    NSMutableDictionary *subRoutes = [self addURLPattern:URLPattern];
    if (block && subRoutes) {
        subRoutes[LMQ_ROUTER_BLOCK_DATA_KEY] = [block copy];
    }
}

- (void)addURLPattern:(NSString *)URLPattern andObjectBlock:(LMQRouterObjectBlock)block
{
    NSMutableDictionary *subRoutes = [self addURLPattern:URLPattern];
    if (block && subRoutes) {
        subRoutes[LMQ_ROUTER_BLOCK_DATA_KEY] = [block copy];
    }
}

- (NSMutableDictionary *)addURLPattern:(NSString *)URLPattern
{
    NSArray *pathComponents = [LMQRouterTool pathComponentsFromURL:URLPattern];
    
    NSMutableDictionary* subRoutes = self.routes;
    
    for (NSString* pathComponent in pathComponents) {
        if (![subRoutes objectForKey:pathComponent]) {
            subRoutes[pathComponent] = [[NSMutableDictionary alloc] init];
        }
        subRoutes = subRoutes[pathComponent];
    }
    return subRoutes;
}

#pragma mark - remove

- (void)removeURLPattern:(NSString *)URLPattern
{
    NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:[LMQRouterTool pathComponentsFromURL:URLPattern]];
    
    // 只删除该 pattern 的最后一级
    if (pathComponents.count >= 1) {
        // 假如 URLPattern 为 a/b/c, components 就是 @"a.b.c" 正好可以作为 KVC 的 key
        NSString *components = [pathComponents componentsJoinedByString:@"."];
        NSMutableDictionary *route = [self.routes valueForKeyPath:components];
        
        if (route.count >= 1) {
            NSString *lastComponent = [pathComponents lastObject];
            [pathComponents removeLastObject];
            
            // 有可能是根 key，这样就是 self.routes 了
            route = self.routes;
            if (pathComponents.count) {
                NSString *componentsWithoutLast = [pathComponents componentsJoinedByString:@"."];
                route = [self.routes valueForKeyPath:componentsWithoutLast];
            }
            [route removeObjectForKey:lastComponent];
        }
    }
}

#pragma mark total

+ (NSString *)generateURLWithPattern:(NSString *)pattern parameters:(NSArray *)parameters
{
    return [LMQRouterTool generateURLWithPattern:pattern parameters:parameters];
}

+ (NSMutableDictionary *)extractParametersFromURL:(NSString *)url withRoutes:(NSMutableDictionary *)routes matchExactly:(BOOL)exactly
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[LMQRouterParameterURLKey] = url;
    
    NSMutableDictionary* subRoutes = routes;
    NSArray* pathComponents = [LMQRouterTool pathComponentsFromURL:url];
    
    BOOL found = NO;
    for (NSString* pathComponent in pathComponents) {
        NSArray *subRoutesKeys =[subRoutes.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2];
        }];
        
        for (NSString* key in subRoutesKeys) {
            if ([key isEqualToString:pathComponent] || [key isEqualToString:LMQ_ROUTER_PLACEHOLDER_CHARACTER]) {
                found = YES;
                subRoutes = subRoutes[key];
                break;
            } else if ([key hasPrefix:@":"]) {
                found = YES;
                subRoutes = subRoutes[key];
                NSString *newKey = [key substringFromIndex:1];
                NSString *newPathComponent = pathComponent;
                // if :id.html -> :id
                if ([LMQRouterTool checkIfContainsSpecialCharacter:key]) {
                    NSCharacterSet *specialCharacterSet = [NSCharacterSet characterSetWithCharactersInString:URLSpecialCharacters];
                    NSRange range = [key rangeOfCharacterFromSet:specialCharacterSet];
                    if (range.location != NSNotFound) {
                        newKey = [newKey substringToIndex:range.location - 1];
                        NSString *suffixToStrip = [key substringFromIndex:range.location];
                        newPathComponent = [newPathComponent stringByReplacingOccurrencesOfString:suffixToStrip withString:@""];
                    }
                }
                parameters[newKey] = newPathComponent;
                break;
            } else if (exactly) {
                found = NO;
            }
        }
        
        if (!found && !subRoutes[LMQ_ROUTER_BLOCK_DATA_KEY]) {
            return nil;
        }
    }
    
    NSArray<NSURLQueryItem *> *queryItems = [[NSURLComponents alloc] initWithURL:[[NSURL alloc] initWithString:url] resolvingAgainstBaseURL:false].queryItems;
    
    for (NSURLQueryItem *item in queryItems) {
        parameters[item.name] = item.value;
    }
    
    if (subRoutes[LMQ_ROUTER_BLOCK_DATA_KEY]) {
        parameters[LMQRouterParameterBlockKey] = [subRoutes[LMQ_ROUTER_BLOCK_DATA_KEY] copy];
    }
    
    return parameters;
}


#pragma mark - setter & getter
- (NSMutableDictionary *)routes
{
    if (_routes == nil) {
        _routes = [NSMutableDictionary dictionary];
    }
    return _routes;
}

@end
