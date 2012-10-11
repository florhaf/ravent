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
    
    UIView *_footer;
    UILabel *_noFriendLabel;
}

- (id)initWithEvent:(models_Event *)event;
- (void)onLoadInvited:(NSArray *)objects;
- (models_User *)getUserForRow:(NSInteger)row;
- (void)mydealloc;

@end
