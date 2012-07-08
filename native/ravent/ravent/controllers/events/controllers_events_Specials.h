//
//  controllers_events_Specials.h
//  ravent
//
//  Created by florian haftman on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "models_Event.h"
#import "MKTickerView.h"

@interface controllers_events_Specials : UIViewController<MKTickerViewDataSource> {
    
    models_Event *_event;
    NSArray *_tickerItems;
    
    IBOutlet MKTickerView *_ticker;
    IBOutlet UILabel *_labelLocation;
    IBOutlet UILabel *_labelAddress;
    IBOutlet UILabel *_labelOfferTitle;
    IBOutlet UILabel *_labelOfferDescription;
    IBOutlet UILabel *_labelRule;
    
}

- (id)initWithEvent:(models_Event *)event;

@end
