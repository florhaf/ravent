//
//  EventDispatcher.m
//  ravent
//
//  Created by florian haftman on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ActionDispatcher.h"

@implementation ActionDispatcher

static ActionDispatcher *dispatcher = nil;

- (id) init
{
    self = [super init];
    
    if (self != nil) {
        
        _actions = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (BOOL)containsActionNamed:(NSString *)action
{
    for (NSString *crtAction in [_actions allKeys]) {
        
        if ([crtAction isEqualToString:action]) {
            
            return true;
        }
    }
    
    return false;
}

- (void)add:(Action *)action named:(NSString *)name
{
    if (action != nil && name != nil) {
     
        [_actions setValue:action forKey:name];
    }
}

- (void)del:(NSString *)name
{
    [_actions removeObjectForKey:name];
}

- (void)execute:(NSString *)name
{
    Action *action = [_actions valueForKey:name];
    
    if (action != nil) {
        
        [action execute];
    }
}

- (void)execute:(NSString *)name with:(NSArray *)objects
{
    Action *action = [_actions valueForKey:name];
    
    if (action != nil) {
        
        [action executeWith:objects];
    }
}

- (void)execute:(NSString *)name withBool:(BOOL)value
{
    Action *action = [_actions valueForKey:name];
    
    if (action != nil) {
        
        [action executeWithBool:value];
    }
}

- (void)execute:(NSString *)name withString:(NSString *)value
{
    Action *action = [_actions valueForKey:name];
    
    if (action != nil) {
        
        [action executeWithString:value];
    }
}

+ (ActionDispatcher *)instance
{
    if (dispatcher == nil) {
        
        dispatcher = [[ActionDispatcher alloc] init];
    }
    
    return dispatcher;
}

@end
