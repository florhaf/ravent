//
//  controllers_watchlist_Container.m
//  ravent
//
//  Created by florian haftman on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_watchlist_Container.h"
#import <EventKit/EKEventStore.h>
#import <EventKit/EKEvent.h>
#import "Store.h"
#import "YRDropdownView.h"
#import "controllers_App.h"

@implementation controllers_watchlist_Container

static customNavigationController *_ctrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forUser:(models_User *)user
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        _user = user;
        self.title = @"Watchlist";
        
    }
    return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addChildViewController:[controllers_watchlist_WatchList instance]];
    
    [self.view addSubview:[controllers_watchlist_WatchList instance].view];
    
    UIImage *menubg = [UIImage imageNamed:@"navBarBG"];
    UIImage *menui = [UIImage imageNamed:@"navBarMenu"];
    
    UIButton *menub = [UIButton buttonWithType:UIButtonTypeCustom];
    [menub addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    [menub setImage:menui forState:UIControlStateNormal];
    [menub setBackgroundImage:menubg forState:UIControlStateNormal];
    [menub setFrame:CGRectMake(0, 0, 40, 29)];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:menub];
    self.navigationItem.leftBarButtonItem = menuButton; 
    
    
    // shadows
    UIImageView *ivright = [[UIImageView alloc] initWithFrame:CGRectMake(320, 0, 40, 460)];
    [ivright setImage:[UIImage imageNamed:@"shadowRight"]];
    [self.slidingViewController.topViewController.view addSubview:ivright];
    
    UIImageView *ivleft = [[UIImageView alloc] initWithFrame:CGRectMake(-40, 0, 40, 460)];
    [ivleft setImage:[UIImage imageNamed:@"shadowLeft"]];
    [self.slidingViewController.topViewController.view addSubview:ivleft];
    
    UIImageView *ivtop = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    [ivtop setImage:[UIImage imageNamed:@"shadowTop"]];
    [self.view addSubview:ivtop];
    
    
    UIImageView *toolbar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grayToolbar"]];
    [toolbar setFrame:CGRectMake(0, 372, 320, 44)];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(30, 376, 260, 35)];
    [btn setBackgroundImage:[UIImage imageNamed:@"askButton"] forState:UIControlStateNormal];
    [btn setTitle:@"Sync with Calendar" forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    [btn addTarget:self action:@selector(syncWithCal) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:toolbar];
    [self.view addSubview:btn];
}

- (void)syncWithCal
{
    NSArray *events = [controllers_watchlist_WatchList instance].data;
    EKEventStore *eventStore = [[EKEventStore alloc] init];    
    
    for (models_Event *e in events) {
        
        if (!e.isSyncedWithCal) {
         
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MMM d, yyyy hh:mm a"];
            
            EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
            event.title     = e.name;
            
            event.startDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",  e.dateStart, e.timeStart]];
            event.endDate   = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",  e.dateStart, e.timeStart]];
            
            event.location = e.location;
            
            event.notes = @"Brought to you by Gemster";
            
            [event setCalendar:[eventStore defaultCalendarForNewEvents]];
            NSError *err;
            [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
            
            e.isSyncedWithCal = YES;
            
            [[Store instance] update:e];
        }
    }
    
    [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                 title:@"Watchlist" 
                                detail:@"Watchlist is now synchronized with your calendar"
                                 image:[UIImage imageNamed:@"dropdown-alert"]
                              animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[controllers_SlidingMenu class]]) {
        self.slidingViewController.underLeftViewController  = [controllers_SlidingMenu instance];
    }
    
    if (self.slidingViewController.underRightViewController != nil) {
        self.slidingViewController.underRightViewController = nil;
    }
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.slidingViewController.topViewController.view removeGestureRecognizer:[self.slidingViewController panGesture]];
}

- (void)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

+ (customNavigationController *)instance
{
    if (_ctrl == nil) {
        
        controllers_watchlist_Container *events = [[controllers_watchlist_Container alloc] initWithNibName:nil bundle:nil forUser:[[models_User crtUser] copy]];
        _ctrl = [[customNavigationController alloc] initWithRootViewController:events];
    }
    
    return _ctrl;
}

+ (void)release
{
    [controllers_watchlist_WatchList release];
    _ctrl = nil;
}

@end
