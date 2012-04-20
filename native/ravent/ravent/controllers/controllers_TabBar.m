//
//  controllers_App.m
//  ravent
//
//  Created by florian haftman on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_TabBar.h"

#import "customNavigationController.h"
#import "controllers_events_Events.h"
#import "controllers_friends_People.h"
#import "controllers_calendar_Calendar.h"
#import "controllers_stats_Stats.h"

@implementation controllers_TabBar

- (id)init
{
    
    self = [super init];
    
    if (self) {
    
        // TAB 1
        // *******************************************************
        controllers_events_Events *events = [[controllers_events_Events alloc] initWithNibName:nil bundle:nil forUser:[[models_User crtUser] copy]];
        customNavigationController *eventsNav = [[customNavigationController alloc] initWithRootViewController:events];
        
        eventsNav.title = @"Events";
        eventsNav.tabBarItem.image = [UIImage imageNamed:@"first"];
        // *******************************************************
        
        // TAB 2
        // *******************************************************
        controllers_friends_People *friendsList = [[controllers_friends_People alloc] initWithUser:[[models_User crtUser] copy]];
        customNavigationController *friendsNav = [[customNavigationController alloc] initWithRootViewController:friendsList];
        
        friendsNav.title = @"People";
        friendsNav.tabBarItem.image = [UIImage imageNamed:@"first"];
        // *******************************************************
        
        // TAB 3
        // *******************************************************
        controllers_calendar_Calendar *calendar = [[controllers_calendar_Calendar alloc] init];
        
        calendar.title = @"Calendar";
        calendar.tabBarItem.image = [UIImage imageNamed:@"first"];
        // *******************************************************
        
        // TAB 4
        // *******************************************************
        controllers_stats_Stats *options = [[controllers_stats_Stats alloc] initWithNibName:@"views_stats_Stats" bundle:[NSBundle mainBundle]];
        
        options.title = @"Stats";
        options.tabBarItem.image = [UIImage imageNamed:@"first"];
        // *******************************************************
        
        self.viewControllers = [NSArray arrayWithObjects:eventsNav, friendsNav, calendar, options, nil];
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

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
 {
 }
 */

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
 {
 }
 */

@end
