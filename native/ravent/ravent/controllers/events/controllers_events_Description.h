//
//  controllers_events_Description.h
//  ravent
//
//  Created by florian haftman on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "models_Event.h"

@interface controllers_events_Description : UIViewController {
    
    UILabel *_descriptionLabel;
    UIScrollView *_scrollview;
    
    models_Event *_event;
}

@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil event:(models_Event *)event;

@end
