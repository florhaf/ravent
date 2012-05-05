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
    
    IBOutlet UITextView *_textView;
    
    models_Event *_event;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil event:(models_Event *)event;

@end
