//
//  controllers_friends_Details.h
//  ravent
//
//  Created by florian haftman on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UItableViewEvents.h"

@interface controllers_friends_Details : UITableViewEvents {
    
    IBOutlet UIView *_detailsView;
    IBOutlet UILabel *_nameLabel;
    IBOutlet UILabel *_followingLabel;
    IBOutlet UILabel *_followersLabel;
    IBOutlet UILabel *_eventsLabel;
    IBOutlet JBAsyncImageView *_userImage;
    IBOutlet UIButton *_fbButton;
}

- (void)onUserLoad:(NSArray *)objects;

@end
