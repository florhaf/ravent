//
//  EventDispatcher.h
//  ravent
//
//  Created by florian haftman on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Action.h"

@interface ActionDispatcher : NSObject {
    
    NSMutableDictionary *_actions;
}

- (id)init;
- (void)add:(Action *)action named:(NSString *)name;
- (void)del:(NSString *)name;
- (void)execute:(NSString *)name;
- (void)execute:(NSString *)name with:(NSArray *)objects;
- (void)execute:(NSString *)name withBool:(BOOL)value;
- (void)execute:(NSString *)name withString:(NSString *)value;
- (BOOL)containsActionNamed:(NSString *)action;

+ (ActionDispatcher *)instance;

@end
