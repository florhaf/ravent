//
//  AppDelegate.m
//  ravent
//
//  Created by florian haftman on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "controllers_Login.h"
#import "customNavigationController.h"
#import "controllers_events_Events.h"
#import "controllers_friends_People.h"
#import "controllers_calendar_Calendar.h"
#import "controllers_stats_Stats.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize loginController = _loginController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque];
    
    
    [self showApp];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)showApp
{
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
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:eventsNav, friendsNav, calendar, options, nil];
    
    self.window.rootViewController = self.tabBarController;
}

- (void)showLogin
{
    self.loginController = [[controllers_Login alloc] initWithNibName:@"views_Login" bundle:nil];
    
    self.window.rootViewController = self.loginController;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
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
