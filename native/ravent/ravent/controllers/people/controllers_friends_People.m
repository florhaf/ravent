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
#import "MBProgressHUD.h"
#import "ActionDispatcher.h"

@implementation controllers_friends_People

static customNavigationController *_ctrl;

- (id)initWithUser:(models_User *)user
{
    self = [super init];
    
    if (self) {
        
        self.title = @"Ravent";
        _user = user;
          
        Action *loadAction = [[Action alloc] initWithDelegate:self andSelector:@selector(loadData)];
        Action *isLoadedAction = [[Action alloc] initWithDelegate:self andSelector:@selector(isLoaded:)];
        Action *showSpinnerAction = [[Action alloc] initWithDelegate:self andSelector:@selector(showSpinner)];
        Action *hideSpinnerAction = [[Action alloc] initWithDelegate:self andSelector:@selector(hideSpinner)];
        
        [[ActionDispatcher instance] add:loadAction named:@"reloadCurrentUser"];
        [[ActionDispatcher instance] add:isLoadedAction named:@"followingIsLoaded"];
        [[ActionDispatcher instance] add:showSpinnerAction named:@"showFollowSpinner"];
        [[ActionDispatcher instance] add:hideSpinnerAction named:@"hideFollowSpinner"];
        
        [[NSBundle mainBundle] loadNibNamed:@"views_friends_header_Following" owner:self options:nil];
        
        CGRect frame = CGRectMake(0, 0, 320,  367 - _header.frame.size.height);
        _following = [[controllers_friends_Following alloc] initWithFrame:frame withUser:[_user copy] isFollowing:YES];
        _followers = [[controllers_friends_Following alloc] initWithFrame:frame withUser:[_user copy] isFollowing:NO];
        
        [self addChildViewController:_following];
        [self addChildViewController:_followers];
        
        _isFollowersLoaded = NO;
        _isFollowingLoaded = NO;
    }
    
    return self;
}

- (void)isLoaded:(NSString *)isFollowing
{
    if ([isFollowing isEqualToString:@"true"]) {
        
        _isFollowingLoaded = YES;
    } else {
        
        _isFollowersLoaded = YES;
    }
}

- (void)showSpinner
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)hideSpinner
{
    if (_isFollowersLoaded || _isFollowingLoaded) {
     
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
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
    controllers_friends_Details *details = [[controllers_friends_Details alloc] initWithUser:[[models_User crtUser] copy]];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: nil action: nil];
    UIViewController *rootController = self;
    
    while (![rootController.parentViewController isKindOfClass:[UINavigationController class]]) {
        
        rootController = rootController.parentViewController;
    }
    
    [rootController.navigationItem setBackBarButtonItem: backButton];
    [self.navigationController pushViewController:details animated:YES];
}

- (void)showAllModal
{
    controllers_friends_All *friendsAll = [[controllers_friends_All alloc] initWithUser:[_user copy] following:_following.groupedData];
    UINavigationController *friendsAllModal = [[UINavigationController alloc] initWithRootViewController:friendsAll];
    
    [self presentModalViewController:friendsAllModal animated:YES];
}

- (void)flipView
{
    UIView *ing = _following.view;
    UIView *ers = _followers.view;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.8];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[self.view.subviews objectAtIndex:1] cache:YES];
	
	if ([ing superview]) {
        
		[ing removeFromSuperview];
		[[self.view.subviews objectAtIndex:1] addSubview:ers];
        self.navigationItem.rightBarButtonItem.title = @"F'ing";
    } else {
        
		[ers removeFromSuperview];
		[[self.view.subviews objectAtIndex:1] addSubview:ing];
        self.navigationItem.rightBarButtonItem.title = @"F'er";
    }
    
	[UIView commitAnimations];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *allButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(revealMenu:)];          
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc] initWithTitle:@"All" style:UIBarButtonItemStylePlain target:self action:@selector(revealAll:)];          
    
    self.navigationItem.leftBarButtonItem = allButton;
    self.navigationItem.rightBarButtonItem = flipButton;
    
    // make the header clickable
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = _header.frame;
    [btn addTarget:self action:@selector(onMeTap) forControlEvents:UIControlEventTouchUpInside];
    [_header addSubview:btn];
    
    UIView *tableContainer = [[UIView alloc] initWithFrame:CGRectMake(0, _header.frame.size.height, 320,  367 - _header.frame.size.height)];
    tableContainer.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_header];
    [self.view addSubview:tableContainer];
    
    [self showSpinner];
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
    
//    if (![self.slidingViewController.underRightViewController isKindOfClass:[controllers_events_Map_p2p class]]) {
//        self.slidingViewController.underRightViewController = _mapController;
//    }
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)revealAll:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECLeft];
}

+ (customNavigationController *)instance 
{
    if (_ctrl == nil) {
        
        controllers_friends_People *friendsList = [[controllers_friends_People alloc] initWithUser:[[models_User crtUser] copy]];
        _ctrl = [[customNavigationController alloc] initWithRootViewController:friendsList];
    }
    
    return _ctrl;
}

@end
