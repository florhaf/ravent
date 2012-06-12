//
//  Action.h
//  ravent
//
//  Created by florian haftman on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Action : NSObject {
    
    id __unsafe_unretained _delegate;
    SEL _selector;
}

@property (unsafe_unretained) id delegate;
@property (nonatomic, assign) SEL selector;

- (id)initWithDelegate:(id)delegate andSelector:(SEL)selector;
- (void)execute;
- (void)executeWith:(NSArray *)objects;
- (void)executeWithBool:(BOOL)value;
- (void)executeWithString:(NSString *)value;

@end
