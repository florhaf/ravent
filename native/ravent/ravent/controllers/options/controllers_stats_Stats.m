//
//  controllers_stats_Stats.m
//  ravent
//
//  Created by florian haftman on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_stats_Stats.h"

@implementation controllers_stats_Stats

static customNavigationController *_ctrl;

- (void)loadData
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *menui = [UIImage imageNamed:@"menuButton"];
    
    UIButton *menub = [UIButton buttonWithType:UIButtonTypeCustom];
    [menub addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    [menub setImage:menui forState:UIControlStateNormal];
    [menub setFrame:CGRectMake(0, 0, menui.size.width, menui.size.height)];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:menub];
    self.navigationItem.leftBarButtonItem = menuButton;    
}

- (void)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
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
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

+ (customNavigationController *)instance
{
    if (_ctrl == nil) {
        
        controllers_stats_Stats *stats = [[controllers_stats_Stats alloc] init];
        
        _ctrl = [[customNavigationController alloc] initWithRootViewController:stats];;
    }
    
    return _ctrl;
}

@end
