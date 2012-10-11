//
//  controllers_events_FeedContainer.h
//  ravent
//
//  Created by florian haftman on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "models_Event.h"
#import "controllers_events_Feed.h"
#import "postController.h"

@interface controllers_events_FeedContainer : UIViewController {
    
    controllers_events_Feed *_feedController;
    models_Event *_event;
    
    IBOutlet UIToolbar *_toolbar;
    IBOutlet UIBarButtonItem *_button;
}

- (id)initWithEvent:(models_Event *)event;
- (void)mydealloc;

- (IBAction)onCommentTap:(id)sender;

@end
