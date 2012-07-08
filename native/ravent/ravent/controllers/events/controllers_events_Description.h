//
//  controllers_events_Description.h
//  ravent
//
//  Created by florian haftman on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "models_Event.h"
#import "MKTickerView.h"

@interface controllers_events_Description : UIViewController {
    
    IBOutlet UITextView *_textView;
    NSArray *_tickerItems;
    
    IBOutlet MKTickerView *_ticker;
    IBOutlet UILabel *_labelLocation;
    IBOutlet UILabel *_labelAddress;
    
    models_Event *_event;
    MBProgressHUD *_hud;
    NSString *_url;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil event:(models_Event *)event;

@end
