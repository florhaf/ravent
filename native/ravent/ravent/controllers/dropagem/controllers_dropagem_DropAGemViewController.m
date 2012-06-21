//
//  controllers_dropagem_DropAGemViewController.m
//  ravent
//
//  Created by florian haftman on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_dropagem_DropAGemViewController.h"
#import "YRDropdownView.h"
#import "controllers_dropagem_List.h"
#import "controllers_events_Details.h"
#import "ActionDispatcher.h"


@implementation controllers_dropagem_DropAGemViewController


static customNavigationController *_ctrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forUser:(models_User *)user
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        _user = user;
        self.title = @"Ravent";
        
    }
    return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addChildViewController:[controllers_dropagem_List instance]];
    
    [self.view addSubview:[controllers_dropagem_List instance].view];
    
    UIImage *menui = [UIImage imageNamed:@"menuButton"];
    
    UIButton *menub = [UIButton buttonWithType:UIButtonTypeCustom];
    [menub addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    [menub setImage:menui forState:UIControlStateNormal];
    [menub setFrame:CGRectMake(0, 0, menui.size.width, menui.size.height)];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:menub];
    self.navigationItem.leftBarButtonItem = menuButton;
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

- (void)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

+ (customNavigationController *)instance
{
    if (_ctrl == nil) {
        
        controllers_dropagem_DropAGemViewController *events = [[controllers_dropagem_DropAGemViewController alloc] initWithNibName:nil bundle:nil forUser:[[models_User crtUser] copy]];
        _ctrl = [[customNavigationController alloc] initWithRootViewController:events];
    }
    
    return _ctrl;
}

+ (void)release
{
    [controllers_dropagem_List release];
    _ctrl = nil;
}

@end
