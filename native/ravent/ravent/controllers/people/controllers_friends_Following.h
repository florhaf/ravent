//
//  controllers_friends_Following.h
//  ravent
//
//  Created by florian haftman on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UITableViewReloadable.h"

@interface controllers_friends_Following : UITableViewReloadable {
    
    IBOutlet UILabel *_followingLabel;
    IBOutlet UILabel *_followersLabel;
    IBOutlet UILabel *_eventsLabel;
    
    CGRect _frame;
    BOOL _isFollowing;
    
    UIViewController *_details;
}

- (id)initWithUser:(models_User *)user isFollowing:(BOOL)value;
- (void)onLoadFollowings:(NSArray *)objects;

@end
