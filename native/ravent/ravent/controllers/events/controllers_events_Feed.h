//
//  controllers_events_Feed.h
//  ravent
//
//  Created by florian haftman on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UITableViewReloadable.h"
#import "models_Comment.h"

@interface controllers_events_Feed : UITableViewReloadable {

    models_Comment *_comment;
    
    IBOutlet UILabel *_itemTime;
}

- (id)initWithEvent:(models_Event *)event;

@end
