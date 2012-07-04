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
#import "UIView+Animation.h"
#import "TSPopoverController.h"
#import "TSActionSheet.h"

@implementation controllers_events_Events

static customNavigationController *_ctrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forUser:(models_User *)user
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        _user = user;
        self.title = @"Gemster";
        _isUp = YES;
        
        Action *loadDetailsAction = [[Action alloc] initWithDelegate:self andSelector:@selector(loadEventDetailsFromMap:)];
        [[ActionDispatcher instance] add:loadDetailsAction named:@"controller_events_List_p2p_loadDetails"];
        
        [self addChildViewController:[controllers_events_List_p2p instance]];
        
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
    
    [self.view addSubview:[controllers_events_List_p2p instance].view];
    
    UIImage *menubg = [UIImage imageNamed:@"navBarBG"];
    UIImage *menui = [UIImage imageNamed:@"navBarMenu"];
    
    UIButton *menub = [UIButton buttonWithType:UIButtonTypeCustom];
    [menub addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    [menub setImage:menui forState:UIControlStateNormal];
    [menub setBackgroundImage:menubg forState:UIControlStateNormal];
    [menub setFrame:CGRectMake(0, 0, 40, 29)];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:menub];
    self.navigationItem.leftBarButtonItem = menuButton;

    UIImage *mapbg = [UIImage imageNamed:@"navBarBG"];
    UIImage *mapi = [UIImage imageNamed:@"navBarMap"];
    
    UIButton *mapb = [UIButton buttonWithType:UIButtonTypeCustom];
    [mapb addTarget:self action:@selector(revealMap:) forControlEvents:UIControlEventTouchUpInside];
    [mapb setImage:mapi forState:UIControlStateNormal];
    [mapb setBackgroundImage:mapbg forState:UIControlStateNormal];
    [mapb setFrame:CGRectMake(0, 0, 40, 29)];
    
    UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithCustomView:mapb];        
    self.navigationItem.rightBarButtonItem = mapButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectFirstNonEmptyList) name:@"onLoadEventsP2P" object:[controllers_events_List_p2p instance]];
    
    
    // OPTIONS
    [self.view bringSubviewToFront:_optionsView];
    
    _radiusStepper.value = [models_User crtUser].searchRadius;
    _radiusStepper.minimumValue = 5;
    _radiusStepper.maximumValue = 50;
    _radiusStepper.stepValue = 5;
    _radiusStepper.continuous = NO;
    
    _windowStepper.value = [models_User crtUser].searchWindow / 24;
    _windowStepper.minimumValue = 1;
    _windowStepper.maximumValue = 30;
    _windowStepper.stepValue = 1;
    _windowStepper.continuous = NO;
    
    
    _optionsView.layer.shadowOffset = CGSizeZero;
    _optionsView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_optionsView.layer.bounds].CGPath;
    _optionsView.layer.shadowOpacity = 0.75f;
    _optionsView.layer.shadowRadius = 10.0f;
    _optionsView.layer.shadowColor = [UIColor blackColor].CGColor;
}

- (void)setNavBarTitle:(NSString *)imageName
{
    
    UIImage *i = [UIImage imageNamed:imageName];
    UIImageView *iv = [[UIImageView alloc] initWithImage:i];
    iv.frame = CGRectMake(0, 0, 80, 36);
    
    UIButton *btn = [[UIButton alloc] initWithFrame:iv.frame];
    [btn addTarget:self action:@selector(onSO_Tap:) forControlEvents:UIControlEventTouchUpInside];
    [btn addSubview:iv];
    
    self.navigationItem.titleView = btn;
}

- (void)selectFirstNonEmptyList
{
    controllers_events_List_p2p *c = [controllers_events_List_p2p instance];
    
    if (c.party != nil && [c.party count] > 0) {
        
        [self onPartyButton_Tap:nil];
    } else if (c.chill != nil && [c.chill count] > 0) {
        
        [self onChillButton_Tap:nil];
    } else if (c.art != nil && [c.art count] > 0) {
        
        [self onArtButton_Tap:nil];
    } else if (c.other != nil && [c.other count] > 0) {
        
        [self onMiscButton_Tap:nil];
    } else {
        
        // default to party if everything is empty
        [self onPartyButton_Tap:nil];
    }
}

- (IBAction)onSO_Tap:(id)sender
{
    
    if (_isUp) {
        
        _isUp = NO;
        
        [_optionsView raceTo:CGPointMake(0, -50) withSnapBack:YES];   
       
    } else {
        
        _isUp = YES;
        [_optionsView raceTo:CGPointMake(0, -244) withSnapBack:YES];
        if (_isDirty) {
            
            _isDirty = NO;
            [[controllers_events_List_p2p instance] loadDataWithSpinner];
        }
    }
}

-(void)showPopover:(id)sender forEvent:(UIEvent*)event
{
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.view.frame = CGRectMake(0,0, 320, 400);
    TSPopoverController *popoverController = [[TSPopoverController alloc] initWithContentViewController:tableViewController];
    
    popoverController.cornerRadius = 5;
    popoverController.titleText = @"change order";
    popoverController.popoverBaseColor = [UIColor lightGrayColor];
    popoverController.popoverGradient= NO;
    //    popoverController.arrowPosition = TSPopoverArrowPositionHorizontal;
    [popoverController showPopoverWithTouch:event];
    
}

-(void) showActionSheet:(id)sender forEvent:(UIEvent*)event
{
    TSActionSheet *actionSheet = [[TSActionSheet alloc] initWithTitle:@"action sheet"];
    [actionSheet destructiveButtonWithTitle:@"hoge" block:nil];
    [actionSheet addButtonWithTitle:@"hoge1" block:^{
        NSLog(@"pushed hoge1 button");
    }];
    [actionSheet addButtonWithTitle:@"moge2" block:^{
        NSLog(@"pushed hoge2 button");
    }];
    [actionSheet cancelButtonWithTitle:@"Cancel" block:nil];
    actionSheet.cornerRadius = 5;
    
    [actionSheet showWithTouch:event];
}

- (IBAction)stepperRadiusPressed:(UIStepper *)sender
{
    [models_User crtUser].searchRadius = (int)sender.value;
    _labelRadiusValue.text = [NSString stringWithFormat:@"%d mi.",  (int)sender.value];
    _isDirty = YES;
}

- (IBAction)stepperWindowPressed:(UIStepper *)sender
{
    [models_User crtUser].searchWindow = (int)sender.value * 24; // need to send in hours to the WS
    _labelWindowValue.text = [NSString stringWithFormat:@"%d day", (int)sender.value];    
    _isDirty = YES;
}

- (IBAction)onPartyButton_Tap:(id)sender
{
    [self setNavBarTitle:@"navbarTitleParty"];
    
    [[controllers_events_List_p2p instance].tableView scrollRectToVisible:CGRectMake(0, -55, 1, 1) animated:YES];
    
    [[controllers_events_List_p2p instance] reloadTableViewDataSourceWithIndex:0];
    
    [[controllers_events_Map_p2p instance] loadData:[controllers_events_List_p2p instance].data];
}

- (IBAction)onChillButton_Tap:(id)sender
{
    [self setNavBarTitle:@"navbarTitleChill"];
    
    [[controllers_events_List_p2p instance].tableView scrollRectToVisible:CGRectMake(0, -55, 1, 1) animated:YES];
    
    [[controllers_events_List_p2p instance] reloadTableViewDataSourceWithIndex:1];
    
    [[controllers_events_Map_p2p instance] loadData:[controllers_events_List_p2p instance].data];
}

- (IBAction)onArtButton_Tap:(id)sender
{
    [self setNavBarTitle:@"navbarTitleArt"];
    
    [[controllers_events_List_p2p instance].tableView scrollRectToVisible:CGRectMake(0, -55, 1, 1) animated:YES];
    
    [[controllers_events_List_p2p instance] reloadTableViewDataSourceWithIndex:2];
    
    [[controllers_events_Map_p2p instance] loadData:[controllers_events_List_p2p instance].data];
}

- (IBAction)onMiscButton_Tap:(id)sender
{
    [self setNavBarTitle:@"navbarTitleMisc"];
    
    [[controllers_events_List_p2p instance].tableView scrollRectToVisible:CGRectMake(0, -55, 1, 1) animated:YES];
    
    [[controllers_events_List_p2p instance] reloadTableViewDataSourceWithIndex:3];
    
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

- (void)viewWillDisappear:(BOOL)animated
{
    [self.slidingViewController.topViewController.view removeGestureRecognizer:[self.slidingViewController panGesture]];
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
