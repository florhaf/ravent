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
#import "MWPhotoBrowser.h"

@interface controllers_events_Feed : UITableViewReloadable<JBAsyncImageViewDelegate, MWPhotoBrowserDelegate> {

    models_Comment *_comment;
    
    IBOutlet UILabel *_itemTime;
    IBOutlet JBAsyncImageView *_commentImg;
    
    NSMutableArray *_photos;
    
}

- (id)initWithEvent:(models_Event *)event;
-(IBAction)onPictureTap:(id)sender;

@end
