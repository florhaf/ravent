//
//  controllers_friends_share.h
//  ravent
//
//  Created by florian haftman on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UITableViewReloadable.h"

@interface controllers_friends_share : UITableViewReloadable {
    
    NSArray *_invited;
    
    IBOutlet UIButton *_inviteButton;
}

- (id)initWithUser:(models_User *)user invited:(NSArray *)invited;
- (void)loadData:(BOOL)force;
- (void)onLoadAll:(NSArray *)objects;

@end
