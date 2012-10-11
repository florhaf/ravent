//
//  controllers_events_DetailsContainer.m
//  ravent
//
//  Created by florian haftman on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_events_DetailsContainer.h"
#import "controllers_friends_share.h"
#import "controllers_events_Description.h"
#import "controllers_events_FeedContainer.h"
#import "YRDropdownView.h"
#import "controllers_App.h"
#import "models_User.h"

@interface controllers_events_DetailsContainer ()

@end

@implementation controllers_events_DetailsContainer

- (id)initWithEvent:(models_Event *)event
{
    self = [super initWithNibName:@"views_events_Details_Container" bundle:nil];
    
    if (self != nil) {

        self.title = @"Gemster";
        _event = event;
        _detailsController = [[controllers_events_Details alloc] initWithEvent:event];
        [self addChildViewController:_detailsController];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:_detailsController.view];
    [self.view sendSubviewToBack:_detailsController.view];
}

- (IBAction)shareButton_Tap:(id)sender
{
    if (_event.rsvp_status == nil || [_event.rsvp_status isEqualToString:@""] || [_event.rsvp_status isEqualToString:@"not replied"]) {
        
        [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                     title:@"Warning" 
                                    detail:@"Per Facebook policy, you must RSVP to share this event...\n\nHint: you can RSVP no"
                                     image:[UIImage imageNamed:@"dropdown-alert"]
                                  animated:YES];
        
        return;
    }
    
    controllers_friends_share *shareController = [[controllers_friends_share alloc] initWithUser:[[models_User crtUser] copy] invited:_detailsController.data];
    
    UINavigationController *shareModal = [[UINavigationController alloc] initWithRootViewController:shareController];
    
    [self presentModalViewController:shareModal animated:YES];
}

- (IBAction)descriptionButton_Tap:(id)sender
{
    controllers_events_Description *descController = [[controllers_events_Description alloc] initWithNibName:@"views_events_Description" bundle:[NSBundle mainBundle] event:[_event copy]];
    
    UINavigationController *descModal = [[UINavigationController alloc] initWithRootViewController:descController];
    
    [self presentModalViewController:descModal animated:YES];
}

- (IBAction)feedButton_Tap:(id)sender
{
    controllers_events_FeedContainer *feedController = [[controllers_events_FeedContainer alloc] initWithEvent:[_event copy]];
    
    UINavigationController *feedModal = [[UINavigationController alloc] initWithRootViewController:feedController];
    
    [self presentModalViewController:feedModal animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)mydealloc
{    
    [_detailsController mydealloc];
    
    _detailsController = nil;
    
    if (_event) {
        
        [_event mydealloc];
        _event = nil;
    }
}

@end
