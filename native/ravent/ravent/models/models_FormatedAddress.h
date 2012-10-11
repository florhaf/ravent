//
//  models_FormatedAddress.h
//  ravent
//
//  Created by florian haftman on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "models_Event.h"

@interface models_FormatedAddress : NSObject<RKObjectLoaderDelegate, RKRequestDelegate> {
    
    id _delegate;
    SEL _callback;
    
    models_Event *_event;
    RKObjectManager *_manager;  
    NSString *_formatted_address;
}

@property (nonatomic, retain) NSString *formatted_address;

- (id)initWithEvent:(models_Event *)event delegate:(id)delegate callback:(SEL)callback;
- (void)loadAddress;
- (void)mydealloc;

@end
