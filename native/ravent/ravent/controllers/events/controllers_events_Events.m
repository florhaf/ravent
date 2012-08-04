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
#import "NSString+Distance.h"
#import <QuartzCore/QuartzCore.h>
#import "GANTracker.h"
#import "controllers_TakeTheTour.h"

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
    [[controllers_events_List_p2p instance] performSelector:@selector(loadEventDetails:) withObject:e afterDelay:0];
    
    [self.slidingViewController resetTopView];
    
    
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:[controllers_events_List_p2p instance].view];
    
    // TOLBAR BUTTONS
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
    
    
    // OPTIONS
    [self.view bringSubviewToFront:_optionsView];
    
    _radiusStepper.value = [models_User crtUser].searchRadius;
    _radiusStepper.minimumValue = 0;
    _radiusStepper.maximumValue = 50;
    _radiusStepper.stepValue = 5;
    _radiusStepper.continuous = YES;
    
    // format label w/ km or mi
    [self stepperRadiusPressed:_radiusStepper];
    
    _windowStepper.value = [models_User crtUser].searchWindow / 24;
    _windowStepper.minimumValue = 1;
    _windowStepper.maximumValue = 30;
    _windowStepper.stepValue = 1;
    _windowStepper.continuous = YES;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectFirstNonEmptyList) name:@"onLoadEventsP2P" object:[controllers_events_List_p2p instance]];
    
    
    
    // shadows
    UIImageView *ivright = [[UIImageView alloc] initWithFrame:CGRectMake(320, 0, 40, 460)];
    [ivright setImage:[UIImage imageNamed:@"shadowRight"]];
    [self.slidingViewController.topViewController.view addSubview:ivright];
    
    UIImageView *ivleft = [[UIImageView alloc] initWithFrame:CGRectMake(-40, 0, 40, 460)];
    [ivleft setImage:[UIImage imageNamed:@"shadowLeft"]];
    [self.slidingViewController.topViewController.view addSubview:ivleft];
    
    UIImageView *ivtop = [[UIImageView alloc] initWithFrame:CGRectMake(0, _optionsView.frame.size.height, 320, 20)];
    [ivtop setImage:[UIImage imageNamed:@"shadowTop"]];
    [_optionsView addSubview:ivtop];
    
    
    //[self onPartyButton_Tap:nil];
    
}

- (void)setNavBarTitle:(NSString *)title
{
    //self.navigationItem.titleView = nil;
    self.title = @"";
    
    if (_menuButton == nil) {
        
        _menuArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
        [_menuArrow setFrame:CGRectMake(28, 28, 22, 12.5)];
        
        _menuLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -6, 80, 38)];
        _menuLabel.textColor = [UIColor whiteColor];
        _menuLabel.font = [UIFont boldSystemFontOfSize:22];
        _menuLabel.shadowColor = [UIColor darkGrayColor];
        _menuLabel.shadowOffset = CGSizeMake(0, -1);
        _menuLabel.backgroundColor = [UIColor clearColor];
        _menuLabel.textAlignment = UITextAlignmentCenter;
        
        _menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 1, 80, 42)];
        [_menuButton setClipsToBounds:YES];
        [_menuButton addTarget:self action:@selector(onSO_Tap:) forControlEvents:UIControlEventTouchUpInside];
        [_menuButton setBackgroundImage:[UIImage imageNamed:@"navbarTitle"] forState:UIControlStateNormal];
        [_menuButton addSubview:_menuArrow];

        self.navigationItem.titleView = [[UIView alloc] initWithFrame:_menuButton.frame];
        [self.navigationItem.titleView addSubview:_menuButton];
        [self.navigationItem.titleView addSubview:_menuArrow];
        [self.navigationItem.titleView addSubview:_menuLabel];
    }
    
    [UIView animateWithDuration:0.15 animations:^{
        
        [_menuLabel setAlpha:0];
    } completion:^(BOOL finished) {
        
        
        _menuLabel.text = title;
        [UIView animateWithDuration:0.15 animations:^(){
           
            [_menuLabel setAlpha:1];    
        }];
    }];
    
    if (!_isUp) {
     
        [self onSO_Tap:nil];
    }
}

- (void)selectFirstNonEmptyList
{
    controllers_events_List_p2p *c = [controllers_events_List_p2p instance];
    
    if (_currentCategory == 0) {
    
        if (c.party != nil && [c.party count] > 0) {
            
            _currentCategory = 0;
            [self onPartyButton_Tap:nil];
        } else if (c.chill != nil && [c.chill count] > 0) {
            
            _currentCategory = 1;
            [self onChillButton_Tap:nil];
        } else if (c.art != nil && [c.art count] > 0) {
            
            _currentCategory = 2;
            [self onArtButton_Tap:nil];
        } else if (c.other != nil && [c.other count] > 0) {
            
            _currentCategory = 3;
            [self onMiscButton_Tap:nil];
        } else {
            
            // default to party if everything is empty
            _currentCategory = 0;
            [self onPartyButton_Tap:nil];
        }   
    } else {
        
        switch (_currentCategory) {
            case 1:
                [self onChillButton_Tap:nil];
                break;
            case 2:
                [self onArtButton_Tap:nil];
                break;
            case 3:
                [self onMiscButton_Tap:nil];
                break;
            default:
                break;
        }
    }
        
}

- (IBAction)onSO_Tap:(id)sender
{
    if (_isUp) {
        
        _isUp = NO;
        
        [_optionsView raceTo:CGPointMake(0, -20) withSnapBack:YES];   
        
        [UIView animateWithDuration:0.5 animations:^() {
           
            _menuArrow.transform = CGAffineTransformMakeRotation((M_PI / 180.0) * 180.0f);
        }];

        _labelNbParty.text = [NSString stringWithFormat:@"(%d)", [[controllers_events_List_p2p instance].party count]];
        _labelNbChill.text = [NSString stringWithFormat:@"(%d)", [[controllers_events_List_p2p instance].chill count]];
        _labelNbArt.text = [NSString stringWithFormat:@"(%d)", [[controllers_events_List_p2p instance].art count]];
        _labelNbMisc.text = [NSString stringWithFormat:@"(%d)", [[controllers_events_List_p2p instance].other count]];
       
    } else {
        
        _isUp = YES;
        [_optionsView raceTo:CGPointMake(0, -264) withSnapBack:YES];
        
        // change in radius or timeframe, need to call the WS
        if (_isDirty) {
            
            _isDirty = NO;
            [[controllers_events_List_p2p instance] loadDataWithSpinner];
            
            // change sorting no need to call WS
        } else if (_isSemiDirty) {
            
            _isSemiDirty = NO;
            
            switch (_currentCategory) {
                case 0:
                    [self onPartyButton_Tap:nil];
                    break;
                case 1:
                    [self onChillButton_Tap:nil];
                    break;
                case 2:
                    [self onArtButton_Tap:nil];
                    break;
                case 3:
                    [self onMiscButton_Tap:nil];
                    break;
                default:
                    break;
            }
        }
        
        [UIView animateWithDuration:0.5 animations:^() {
            
            _menuArrow.transform = CGAffineTransformMakeRotation((M_PI / 180.0) * 0.0f);
        }];

    }
}

- (IBAction)onSortChanged:(id)sender
{    
    [controllers_events_List_p2p instance].sort = _seg.selectedSegmentIndex;
    [[controllers_events_List_p2p instance] reloadTableViewDataSourceWithIndex:_currentCategory];
}

- (IBAction)stepperRadiusPressed:(UIStepper *)sender
{
    
    
    NSString *format = @"%d";
    int value = ((int)sender.value == 0) ? 1 : (int)sender.value;
    
    
    _isDirty = !(value == [models_User crtUser].searchRadius || value * 1.609344 == [models_User crtUser].searchRadius);
    
    BOOL isMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
    
    if (isMetric) {
        
        format = @"km.";
        [models_User crtUser].searchRadius = value * 1.609344;
    } else {
        
        format = @"mi.";
        [models_User crtUser].searchRadius = value;
    }
    
    _labelRadiusValue.text = [NSString stringWithFormat:@"%d %@",  value, format];
}

- (IBAction)stepperWindowPressed:(UIStepper *)sender
{
    [models_User crtUser].searchWindow = (int)sender.value * 24; // need to send in hours to the WS
    _labelWindowValue.text = [NSString stringWithFormat:@"%d day", (int)sender.value];    
    _isDirty = YES;
}

- (IBAction)onPartyButton_Tap:(id)sender
{
    [[controllers_events_List_p2p instance] reloadTableViewDataSourceWithIndex:0];
    
    [[controllers_events_Map_p2p instance] loadData:[controllers_events_List_p2p instance].data];
    
    _currentCategory = 0;
    
    [self setNavBarTitle:@"Party"];
}

- (IBAction)onChillButton_Tap:(id)sender
{
    
    [[controllers_events_List_p2p instance] reloadTableViewDataSourceWithIndex:1];
    
    [[controllers_events_Map_p2p instance] loadData:[controllers_events_List_p2p instance].data];
    
    _currentCategory = 1;
    
    [self setNavBarTitle:@"Chill"];
    
    
}

- (IBAction)onArtButton_Tap:(id)sender
{
    [[controllers_events_List_p2p instance] reloadTableViewDataSourceWithIndex:2];
    
    [[controllers_events_Map_p2p instance] loadData:[controllers_events_List_p2p instance].data];
    
    _currentCategory = 2;
    
    [self setNavBarTitle:@"Art"];
}

- (IBAction)onMiscButton_Tap:(id)sender
{
    [[controllers_events_List_p2p instance] reloadTableViewDataSourceWithIndex:3];
    
    [[controllers_events_Map_p2p instance] loadData:[controllers_events_List_p2p instance].data];
    
    _currentCategory = 3;
    
    [self setNavBarTitle:@"Misc."];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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

+ (void)deleteInstance
{
    [controllers_events_List_p2p deleteInstance];
    [controllers_events_Map_p2p deleteInstance];
    [controllers_SlidingMenu deleteInstance];
    _ctrl = nil;
}

@end
