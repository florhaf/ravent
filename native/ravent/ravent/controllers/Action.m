//
//  Action.m
//  ravent
//
//  Created by florian haftman on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Action.h"

@implementation Action

@synthesize delegate = _delegate;
@synthesize selector = _selector;

- (id)initWithDelegate:(id)delegate andSelector:(SEL)selector
{
    self = [super init];
    
    if (self != nil) {
        
        _delegate = delegate;
        _selector = selector;
    }
    
    return self;
}

- (void)execute
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_delegate performSelector:_selector];
#pragma clang diagnostic pop
}

- (void)executeWith:(NSArray *)objects
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_delegate performSelector:_selector withObject:objects];
#pragma clang diagnostic pop
}

- (void)executeWithBool:(BOOL)value
{
    NSString *valueStr;
    
    if (value) {
        
        valueStr = @"true";
    } else {
        
        valueStr = @"false";
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_delegate performSelector:_selector withObject:valueStr];
#pragma clang diagnostic pop
}

- (void)executeWithString:(NSString *)value
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_delegate performSelector:_selector withObject:value];
#pragma clang diagnostic pop
}

@end
