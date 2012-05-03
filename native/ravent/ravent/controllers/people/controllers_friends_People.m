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

@implementation controllers_friends_People

static customNavigationController *_ctrl;

- (id)initWithUser:(models_User *)user
{
    self = [super initWithNibName:@"views_friends_People" bundle:nil];
    
    if (self) {
        
        self.title = @"Ravent";
        _user = user;
          
        Action *loadAction = [[Action alloc] initWithDelegate:self andSelector:@selector(loadData)];
        [[ActionDispatcher instance] add:loadAction named:@"reloadCurrentUser"];
        
        [[NSBundle mainBundle] loadNibNamed:@"views_friends_header_Following" owner:self options:nil];
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
    controllers_friends_Details *details = [[controllers_friends_Details alloc] initWithUser:[[models_User crtUser] copy]];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: nil action: nil];
    UIViewController *rootController = self;
    
    while (![rootController.parentViewController isKindOfClass:[UINavigationController class]]) {
        
        rootController = rootController.parentViewController;
    }
    
    [rootController.navigationItem setBackBarButtonItem: backButton];
    [self.navigationController pushViewController:details animated:YES];
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
    
    UIImage *alli = [UIImage imageNamed:@"allButton"];
    UIButton *allb = [UIButton buttonWithType:UIButtonTypeCustom];
    [allb addTarget:self action:@selector(revealAll:) forControlEvents:UIControlEventTouchUpInside];
    [allb setImage:alli forState:UIControlStateNormal];
    [allb setFrame:CGRectMake(0, 0, alli.size.width, alli.size.height)];
    UIBarButtonItem *allButton = [[UIBarButtonItem alloc] initWithCustomView:allb];       
    self.navigationItem.rightBarButtonItem = allButton;
    
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
}

- (IBAction)onSegmentedControlValueChanged
{    
    if (!_isFollowersVisible) {
     
        [self uiview:_following.view raceTo:CGPointMake(-320, 0) withSnapBack:NO];
        [self uiview:_followers.view raceTo:CGPointMake(0, 0) withSnapBack:YES];
        _isFollowersVisible = YES;
    } else {
        
        [self uiview:_following.view raceTo:CGPointMake(0, 0) withSnapBack:YES];
        [self uiview:_followers.view raceTo:CGPointMake(320, 0) withSnapBack:NO];
        _isFollowersVisible = NO;
    }
}

- (void)uiview:(UIView *)uiview raceTo:(CGPoint)destination withSnapBack:(BOOL)withSnapBack
{
    CGPoint stopPoint = destination;
    if (withSnapBack) {
        // Determine our stop point, from which we will "snap back" to the final destination
        int diffx = destination.x - uiview.frame.origin.x;
        int diffy = destination.y - uiview.frame.origin.y;
        if (diffx < 0) {
            // Destination is to the left of current position
            stopPoint.x -= 10.0;
        } else if (diffx > 0) {
            stopPoint.x += 10.0;
        }
        if (diffy < 0) {
            // Destination is to the left of current position
            stopPoint.y -= 10.0;
        } else if (diffy > 0) {
            stopPoint.y += 10.0;
        }
    }
    
    // Do the animation
    [UIView animateWithDuration:0.5 
                          delay:0.0 
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         uiview.frame = CGRectMake(stopPoint.x, stopPoint.y, uiview.frame.size.width, uiview.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (withSnapBack) {
                             [UIView animateWithDuration:0.2 
                                                   delay:0.0 
                                                 options:UIViewAnimationCurveLinear
                                              animations:^{
                                                  uiview.frame = CGRectMake(destination.x, destination.y, uiview.frame.size.width, uiview.frame.size.height);
                                              }
                                              completion:nil];
                         }
                     }];    
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

+ (customNavigationController *)instance 
{
    if (_ctrl == nil) {
        
        controllers_friends_People *friendsList = [[controllers_friends_People alloc] initWithUser:[[models_User crtUser] copy]];
        _ctrl = [[customNavigationController alloc] initWithRootViewController:friendsList];
    }
    
    return _ctrl;
}

@end
