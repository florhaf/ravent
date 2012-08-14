//
//  controllers_friends_People.m
//  ravent
//
//  Created by florian haftman on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_friends_People.h"
#import "controllers_friends_All.h"
#import "controllers_friends_Details.h"
#import "models_User.h"
#import "ActionDispatcher.h"
#import "UIView+Animation.h"

@implementation controllers_friends_People

static customNavigationController *_ctrl;

- (id)initWithUser:(models_User *)user
{
    self = [super initWithNibName:@"views_friends_People" bundle:nil];
    
    if (self) {
        
        self.title = @"People";
        _user = user;
        _isSegTapAllowed = YES;
          
        Action *loadAction = [[Action alloc] initWithDelegate:self andSelector:@selector(loadData)];
        [[ActionDispatcher instance] add:loadAction named:@"reloadCurrentUser"];
        
        [[NSBundle mainBundle] loadNibNamed:@"views_friends_header_Following" owner:self options:nil];
        
        //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"grayBG"]]];
    }
    
    return self;
}

- (void)loadData
{
    _user.delegate = self;
    _user.callback = @selector(onCrtUserLoad:);
    [_user loadUser];
}

- (void)onCrtUserLoad:(NSArray *)objects
{
    _headerEventsLabel.text = @"?";
    _headerFollowersLabel.text = @"?";
    _headerFollowingLabel.text = @"?";

    if (objects == nil || [objects count] == 0) {
        
        return;
    }
    
    models_User *u = (models_User *)[objects objectAtIndex:0];
    
    if ([u isKindOfClass:[NSError class]]) {

        return;
    }
    
    [models_User crtUser].picture = u.picture;
    [models_User crtUser].nbOfEvents = u.nbOfEvents;
    [models_User crtUser].nbOfFollowers = u.nbOfFollowers;
    [models_User crtUser].nbOfFollowing = u.nbOfFollowing;
    
    _headerNameLabel.text = @"Me";
    _headerImage.imageURL = [NSURL URLWithString: [models_User crtUser].picture];
    _headerEventsLabel.text =  [models_User crtUser].nbOfEvents;
    _headerFollowingLabel.text =  [models_User crtUser].nbOfFollowing;
    _headerFollowersLabel.text =  [models_User crtUser].nbOfFollowers;
}

- (void)onMeTap
{
    _details = [[controllers_friends_Details alloc] initWithUser:[[models_User crtUser] copy]];
    
    UIImage *backi = [UIImage imageNamed:@"backButton"];
    
    UIButton *backb = [UIButton buttonWithType:UIButtonTypeCustom];
    [backb addTarget:self action:@selector(onBackTap) forControlEvents:UIControlEventTouchUpInside];
    [backb setImage:backi forState:UIControlStateNormal];
    [backb setFrame:CGRectMake(0, 0, backi.size.width, backi.size.height)];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backb];
    
    UIViewController *rootController = self;
    
    while (![rootController.parentViewController isKindOfClass:[UINavigationController class]]) {
        
        rootController = rootController.parentViewController;
    }
    
    [rootController.navigationItem hidesBackButton];
    [_details.navigationItem setLeftBarButtonItem:backButton];
    [self.navigationController pushViewController:_details animated:YES];
}

- (void)onBackTap
{
    [(controllers_friends_Details *)_details cancelAllRequests];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    UIImage *mapi = [UIImage imageNamed:@"navBarAll"];
    
    UIButton *mapb = [UIButton buttonWithType:UIButtonTypeCustom];
    [mapb addTarget:self action:@selector(revealAll:) forControlEvents:UIControlEventTouchUpInside];
    [mapb setImage:mapi forState:UIControlStateNormal];
    [mapb setBackgroundImage:mapbg forState:UIControlStateNormal];
    [mapb setFrame:CGRectMake(0, 0, 40, 29)];
    
    UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithCustomView:mapb];        
    self.navigationItem.rightBarButtonItem = mapButton;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = _header.frame;
    [btn addTarget:self action:@selector(onMeTap) forControlEvents:UIControlEventTouchUpInside];
    [_header addSubview:btn];

    _following = [[controllers_friends_Following alloc] initWithUser:[_user copy] isFollowing:YES];
    _followers = [[controllers_friends_Following alloc] initWithUser:[_user copy] isFollowing:NO];
            
    [self addChildViewController:_following];
    [self addChildViewController:_followers];
    
    _header.frame = CGRectMake(0, 0, _header.frame.size.width, _header.frame.size.height);
    _following.view.frame = CGRectMake(0, 0, 320, _container.frame.size.height);
    _followers.view.frame = CGRectMake(_following.view.frame.size.width, 0, 320, _container.frame.size.height);
    
    [self.view addSubview:_header];
    [_container addSubview:_following.view];
    [_container addSubview:_followers.view];
    [_container setBackgroundColor:[UIColor clearColor]];
    [_followers.view setHidden:YES];
    
    
    NSArray *objects = [NSArray arrayWithObjects:@"Following", @"Followers", nil];
    _segmentedControl = [[STSegmentedControl alloc] initWithItems:objects];
	_segmentedControl.frame = CGRectMake(44, 380, 232, 30);
	_segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _segmentedControl.selectedSegmentIndex = 0;
    [_segmentedControl addTarget:self action:@selector(onSegmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:_segmentedControl];
    
    
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
}

- (void)onSegmentedControlValueChanged:(id)sender
{    
    
    if (_isSegTapAllowed) {

        _isSegTapAllowed = NO;
        _segmentedControl.enabled = NO;
        
        if (!_isFollowersVisible) {
            
            [_followers.view setHidden:NO];
            _isFollowersVisible = YES;
            [_followers.view setHidden:NO];
            [_following.view raceTo:CGPointMake(-320, 0) withSnapBack:NO];
            
            
            [_followers.view raceTo:CGPointMake(0, 0) withSnapBack:YES withDelegate:self withSelector:@selector(resetIsSegTapAllowed)];
            
        } else {
            
            _isFollowersVisible = NO;
            [_following.view raceTo:CGPointMake(0, 0) withSnapBack:YES];
            [_followers.view raceTo:CGPointMake(320, 0) withSnapBack:YES withDelegate:self withSelector:@selector(resetIsSegTapAllowed)];
            
        }
    }
}

- (void)resetIsSegTapAllowed
{
    _isSegTapAllowed = YES;
    _segmentedControl.enabled = YES;
    
    if (!_isFollowersVisible) {
        
        [_followers.view setHidden:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[controllers_SlidingMenu class]]) {
        self.slidingViewController.underLeftViewController  = [controllers_SlidingMenu instance];
    }
    
    if (![self.slidingViewController.underRightViewController isKindOfClass:[controllers_friends_All class]]) {
        self.slidingViewController.underRightViewController = [controllers_friends_All instance:_following.groupedData];
    }
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)revealAll:(id)sender
{
    [controllers_friends_All instance:_following.groupedData];
    
    [self.slidingViewController anchorTopViewTo:ECLeft];
}

- (void)cancelAllRequests
{
    [_followers cancelAllRequests];
    [_following cancelAllRequests];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.slidingViewController.topViewController.view removeGestureRecognizer:[self.slidingViewController panGesture]];
}

+ (customNavigationController *)instance 
{
    if (_ctrl == nil) {
        
        controllers_friends_People *friendsList = [[controllers_friends_People alloc] initWithUser:[[models_User crtUser] copy]];
        _ctrl = [[customNavigationController alloc] initWithRootViewController:friendsList];
    }
    
    return _ctrl;
}

+ (void)deleteInstance
{
    [((controllers_friends_People *)_ctrl.rootController) cancelAllRequests];
    [controllers_friends_All deleteInstance];
    _ctrl = nil;
}

@end
