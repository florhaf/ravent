//
//  controllers_events_Events.m
//  ravent
//
//  Created by florian haftman on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_events_Events.h"
#import "YRDropdownView.h"
#import "controllers_events_List_p2p.h"
#import "controllers_events_Details.h"
#import "controllers_events_Options_p2p.h"
#import "ActionDispatcher.h"

@implementation controllers_events_Events

static customNavigationController *_ctrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forUser:(models_User *)user
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        _user = user;
        self.title = @"Ravent";
        
        Action *loadDetailsAction = [[Action alloc] initWithDelegate:self andSelector:@selector(loadEventDetailsFromMap:)];
        [[ActionDispatcher instance] add:loadDetailsAction named:@"controller_events_List_p2p_loadDetails"];
        
    }
    return self;
}

- (void)loadEventDetailsFromMap:(NSArray *)objects
{
    models_Event *e = [objects objectAtIndex:0];

    [self.slidingViewController resetTopView];
    
    [[controllers_events_List_p2p instance] performSelector:@selector(loadEventDetails:) withObject:e afterDelay:0.1];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addChildViewController:[controllers_events_Map_p2p instance]];
    [self addChildViewController:[controllers_events_List_p2p instance]];
    
    [self.view addSubview:[controllers_events_List_p2p instance].view];
    
    UIImage *menui = [UIImage imageNamed:@"menuButton"];
    
    UIButton *menub = [UIButton buttonWithType:UIButtonTypeCustom];
    [menub addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    [menub setImage:menui forState:UIControlStateNormal];
    [menub setFrame:CGRectMake(0, 0, menui.size.width, menui.size.height)];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:menub];
    self.navigationItem.leftBarButtonItem = menuButton;

    UIImage *mapi = [UIImage imageNamed:@"mapButton"];
    
    UIButton *mapb = [UIButton buttonWithType:UIButtonTypeCustom];
    [mapb addTarget:self action:@selector(revealMap:) forControlEvents:UIControlEventTouchUpInside];
    [mapb setImage:mapi forState:UIControlStateNormal];
    [mapb setFrame:CGRectMake(0, 0, mapi.size.width, mapi.size.height)];
    
    UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithCustomView:mapb];        
    self.navigationItem.rightBarButtonItem = mapButton;
    
//    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 416, 320, 44)];
//    [_toolbar setBarStyle:UIBarStyleBlackTranslucent];
//    [_toolbar sizeToFit];
//    
//    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:[[NSArray alloc] initWithObjects:@"Party", @"Chill", @"Art", @"All", nil]];
//    [seg setFrame:CGRectMake(0, 0, 200, 40)];
//    [seg setSegmentedControlStyle:UISegmentedControlStyleBar];
//    
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:seg];
//    
//    [_toolbar setItems:[[NSArray alloc] initWithObjects:item, nil]];
//    
//    [self.view addSubview:_toolbar];
    
    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:[[NSArray alloc] initWithObjects:@"Party", @"Chill", @"Art", @"Other", nil]];
    [seg setSegmentedControlStyle:UISegmentedControlStyleBar];
    [seg setTintColor:[UIColor darkGrayColor]];
    [seg setFrame:CGRectMake(0, 0, 310, 30)];
    [seg setSelectedSegmentIndex:0];
    [seg addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:seg];
    
    [_toolbar setItems:[[NSArray alloc] initWithObjects:btn, nil]];
    
    [self.view bringSubviewToFront:_toolbar];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [v setBackgroundColor:[UIColor darkGrayColor]];
    [v setAlpha:0.3];
    
    [_toolbar setBackgroundColor:[UIColor clearColor]];
    [_toolbar insertSubview:v atIndex:1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onValueChanged:) name:@"onLoadEventsP2P" object:[controllers_events_List_p2p instance]];
}

- (IBAction)onValueChanged:(id)sender
{
    UISegmentedControl *seg = (UISegmentedControl *)((UIBarButtonItem *)[_toolbar.items objectAtIndex:0]).customView;
    int selectedIndex = seg.selectedSegmentIndex;
    
    [[controllers_events_List_p2p instance] reloadTableViewDataSourceWithIndex:selectedIndex];
    
    [[controllers_events_Map_p2p instance] loadData:[controllers_events_List_p2p instance].data];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
    // You just need to set the opacity, radius, and color.
    self.parentViewController.view.layer.shadowOpacity = 0.75f;
    self.parentViewController.view.layer.shadowRadius = 10.0f;
    self.parentViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[controllers_SlidingMenu class]]) {
        self.slidingViewController.underLeftViewController  = [controllers_SlidingMenu instance];
    }
    
    if (![self.slidingViewController.underRightViewController isKindOfClass:[controllers_events_Map_p2p class]]) {
        self.slidingViewController.underRightViewController = [controllers_events_Map_p2p instance];
    }
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)revealMap:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECLeft];
}

+ (customNavigationController *)instance
{
    if (_ctrl == nil) {
        
        controllers_events_Events *events = [[controllers_events_Events alloc] initWithNibName:@"views_events_Events" bundle:nil forUser:[[models_User crtUser] copy]];
        _ctrl = [[customNavigationController alloc] initWithRootViewController:events];
    }
    
    return _ctrl;
}

+ (void)release
{
    [controllers_events_List_p2p release];
    [controllers_events_Map_p2p release];
    [controllers_SlidingMenu release];
    _ctrl = nil;
}

@end
