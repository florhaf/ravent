//
//  controllers_Sliding.m
//  ravent
//
//  Created by florian haftman on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_SlidingInitial.h"
#import "controllers_events_Events.h"
#import "controllers_friends_People.h"
#import "controllers_calendar_Calendar.h"
#import "controllers_stats_Stats.h"
#import "customNavigationController.h"

@implementation controllers_SlidingInitial

- (id)init
{
    self = [super init];
    
    if (self != nil) {
        
        self.topViewController = [controllers_events_Events instance];
        
//        Lazy loading is better
//        [controllers_friends_People instance];
//        [controllers_calendar_Calendar instance];
//        [controllers_stats_Stats instance];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
