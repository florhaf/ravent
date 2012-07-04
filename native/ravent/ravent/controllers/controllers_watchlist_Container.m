//
//  controllers_watchlist_Container.m
//  ravent
//
//  Created by florian haftman on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_watchlist_Container.h"


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
    
    
    
    UIView *shadow = [[UIView alloc] initWithFrame:CGRectMake(0, -44, 320, 44)];
    [shadow setBackgroundColor:[UIColor blackColor]];
    
    shadow.layer.shadowOffset = CGSizeZero;
    shadow.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadow.layer.bounds].CGPath;
    shadow.layer.shadowOpacity = 0.75f;
    shadow.layer.shadowRadius = 10.0f;
    shadow.layer.shadowColor = [UIColor blackColor].CGColor;
    
    [self.view addSubview:shadow];
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
