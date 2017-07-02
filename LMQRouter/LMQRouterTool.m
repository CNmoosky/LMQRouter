//
//  LMQRouterTool.m
//  LMQRouter
//
//  Created by lizhengheng on 2017/7/2.
//  Copyright © 2017 limengqi. All rights reserved.
//

#import "LMQRouterTool.h"

static NSString * const URLSpecialCharacters = @"/?&.";

NSString * const LMQ_ROUTER_BLOCK_KEY = @"^";
NSString * const LMQ_ROUTER_PLACEHOLDER_CHARACTER = @"~";

NSString *const LMQRouterParameterBlockKey = @"block";
NSString *const LMQRouterParameterURLKey = @"LMQRouterParameterURLKey";
NSString *const LMQRouterParameterCompletionBlockKey = @"LMQRouterParameterCompletionBlockKey";
NSString *const LMQRouterParameterPrameKey = @"LMQRouterParameterPrameKey";

@implementation LMQRouterTool

+ (NSArray*)pathComponentsFromURL:(NSString*)URL
{
    
    NSMutableArray *pathComponents = [NSMutableArray array];
    if ([URL rangeOfString:@"://"].location != NSNotFound) {
        NSArray *pathSegments = [URL componentsSeparatedByString:@"://"];
        [pathComponents addObject:pathSegments[0]];
        URL = pathSegments.lastObject;
        if (!URL.length) {
            [pathComponents addObject:LMQ_ROUTER_PLACEHOLDER_CHARACTER];
        }
    }
    
    for (NSString *pathComponent in [[NSURL URLWithString:URL] pathComponents]) {
        if ([pathComponent isEqualToString:@"/"]) continue;
        if ([[pathComponent substringToIndex:1] isEqualToString:@"?"]) break;
        [pathComponents addObject:pathComponent];
    }
    return [pathComponents copy];
}

+ (NSMutableDictionary *)extractParametersFromURL:(NSString *)url withRoutes:(NSMutableDictionary *)routes matchExactly:(BOOL)exactly
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[LMQRouterParameterURLKey] = url;
    
    NSMutableDictionary* subRoutes = routes;
    NSArray* pathComponents = [self pathComponentsFromURL:url];
    
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
                if ([self checkIfContainsSpecialCharacter:key]) {
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
        
        if (!found && !subRoutes[LMQ_ROUTER_BLOCK_KEY]) {
            return nil;
        }
    }
    
    NSArray<NSURLQueryItem *> *queryItems = [[NSURLComponents alloc] initWithURL:[[NSURL alloc] initWithString:url] resolvingAgainstBaseURL:false].queryItems;
    
    for (NSURLQueryItem *item in queryItems) {
        parameters[item.name] = item.value;
    }
    
    if (subRoutes[LMQ_ROUTER_BLOCK_KEY]) {
        parameters[LMQRouterParameterBlockKey] = [subRoutes[LMQ_ROUTER_BLOCK_KEY] copy];
    }
    
    return parameters;
}

+ (BOOL)checkIfContainsSpecialCharacter:(NSString *)checkedString {
    NSCharacterSet *specialCharactersSet = [NSCharacterSet characterSetWithCharactersInString:URLSpecialCharacters];
    return [checkedString rangeOfCharacterFromSet:specialCharactersSet].location != NSNotFound;
}


+ (NSString *)generateURLWithPattern:(NSString *)pattern parameters:(NSArray *)parameters
{
    NSInteger startIndexOfColon = 0;
    
    NSMutableArray *placeholders = [NSMutableArray array];
    
    for (int i = 0; i < pattern.length; i++) {
        NSString *character = [NSString stringWithFormat:@"%c", [pattern characterAtIndex:i]];
        if ([character isEqualToString:@":"]) {
            startIndexOfColon = i;
        }
        if ([URLSpecialCharacters rangeOfString:character].location != NSNotFound && i > (startIndexOfColon + 1) && startIndexOfColon) {
            NSRange range = NSMakeRange(startIndexOfColon, i - startIndexOfColon);
            NSString *placeholder = [pattern substringWithRange:range];
            if (![self checkIfContainsSpecialCharacter:placeholder]) {
                [placeholders addObject:placeholder];
                startIndexOfColon = 0;
            }
        }
        if (i == pattern.length - 1 && startIndexOfColon) {
            NSRange range = NSMakeRange(startIndexOfColon, i - startIndexOfColon + 1);
            NSString *placeholder = [pattern substringWithRange:range];
            if (![self checkIfContainsSpecialCharacter:placeholder]) {
                [placeholders addObject:placeholder];
            }
        }
    }
    
    __block NSString *parsedResult = pattern;
    
    [placeholders enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        idx = parameters.count > idx ? idx : parameters.count - 1;
        parsedResult = [parsedResult stringByReplacingOccurrencesOfString:obj withString:parameters[idx]];
    }];
    
    return parsedResult;
}


@end
