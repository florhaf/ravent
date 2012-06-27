//
//  controllers_events_DetailsContainer.h
//  ravent
//
//  Created by florian haftman on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "controllers_events_Details.h"

@interface controllers_events_DetailsContainer : UIViewController {
    
    controllers_events_Details *_detailsController;
    models_Event *_event;
    
    IBOutlet UIToolbar *_toolbar;
    IBOutlet UIView *_container;
    
    id _delegateBack;
    SEL _selectorBack;
    
    UIBarButtonItem *_backButton;
}

@property (nonatomic, retain) id delegateBack;
@property (nonatomic, assign) SEL selectorBack;
@property (nonatomic, retain) UIBarButtonItem *backButton;

- (id)initWithEvent:(models_Event *)event withBackDelegate:(id)delegate backSelector:(SEL)sel;
- (void)cancelAllRequests;
- (IBAction)shareButton_Tap:(id)sender;
- (IBAction)descriptionButton_Tap:(id)sender;
- (IBAction)feedButton_Tap:(id)sender;


@end
