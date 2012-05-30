//
//  UITableViewFriends.h
//  ravent
//
//  Created by florian haftman on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UITableViewReloadable.h"
#import "controllers_friends_Details.h"

@interface UITableViewFriends : UITableViewReloadable {
    
    controllers_friends_Details *_details;
}

- (id)initWithEvent:(models_Event *)event;
- (void)onLoadInvited:(NSArray *)objects;

@end
