//
//  controllers_events_DetailsContainer.m
//  ravent
//
//  Created by florian haftman on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_events_DetailsContainer.h"
#import "controllers_friends_share.h"
#import "controllers_events_Description.h"
#import "controllers_events_FeedContainer.h"
#import "YRDropdownView.h"
#import "controllers_App.h"
#import "models_User.h"

@interface controllers_events_DetailsContainer ()

@end

@implementation controllers_events_DetailsContainer

@synthesize delegateBack = _delegateBack;
@synthesize selectorBack = _selectorBack;
@synthesize backButton = _backButton;

- (id)initWithEvent:(models_Event *)event withBackDelegate:(id)delegate backSelector:(SEL)sel
{
    self = [super initWithNibName:@"views_events_Details_Container" bundle:nil];
    
    if (self != nil) {
        
        _delegateBack = delegate;
        _selectorBack = sel;
        
        self.title = @"Ravent";
        _event = event;
        _detailsController = [[controllers_events_Details alloc] initWithEvent:event withBackDelegate:delegate backSelector:sel];
        _detailsController.view.frame = CGRectMake(0, 0, _detailsController.view.frame.size.width, _detailsController.view.frame.size.height);
        
        [self addChildViewController:_detailsController];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (IBAction)onCommentTap:(id)sender
{
//    postController *post = [[postController alloc] initWithNibName:@"views_Post" bundle:nil];
//    post.isForEvent = YES;
//    post.toId = _event.eid;
//    
//    UINavigationController *postModal = [[UINavigationController alloc] initWithRootViewController:post];
//    
//    [self presentModalViewController:postModal animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _detailsController.view.frame = _container.frame;
    [_container addSubview:_detailsController.view];

    UIButton *buttonShareView = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *buttonDescView = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *buttonFeedView = [UIButton buttonWithType:UIButtonTypeCustom];
    
    buttonShareView.frame = CGRectMake(0, 0, 40, 40);
    buttonDescView.frame = CGRectMake(0, 0, 40, 40);
    buttonFeedView.frame = CGRectMake(0, 0, 40, 40);
    
    [buttonShareView setImage:[UIImage imageNamed:@"grayIconShare"] forState:UIControlStateNormal];
    [buttonDescView setImage:[UIImage imageNamed:@"grayIconDescription"] forState:UIControlStateNormal];
    [buttonFeedView setImage:[UIImage imageNamed:@"grayIconComments"] forState:UIControlStateNormal];
    
    [buttonShareView setImage:[UIImage imageNamed:@"grayIconShareSelected"] forState:UIControlStateHighlighted];
    [buttonDescView setImage:[UIImage imageNamed:@"grayIconDescriptionSelected"] forState:UIControlStateHighlighted];
    [buttonFeedView setImage:[UIImage imageNamed:@"grayIconCommentsSelected"] forState:UIControlStateHighlighted];
    
    [buttonShareView addTarget:self action:@selector(shareButton_Tap:) forControlEvents:UIControlEventTouchUpInside];
    [buttonDescView addTarget:self action:@selector(descriptionButton_Tap:) forControlEvents:UIControlEventTouchUpInside];
    [buttonFeedView addTarget:self action:@selector(feedButton_Tap:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *buttonShare = [[UIBarButtonItem alloc] initWithCustomView:buttonShareView];
    UIBarButtonItem *buttonDesc = [[UIBarButtonItem alloc] initWithCustomView:buttonDescView];
    UIBarButtonItem *buttonFeed = [[UIBarButtonItem alloc] initWithCustomView:buttonFeedView];

    [buttonShare setWidth:buttonShareView.frame.size.width];
    [buttonDesc setWidth:buttonDescView.frame.size.width];
    [buttonFeed setWidth:buttonFeedView.frame.size.width];
    
    [_toolbar insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grayToolbar"]] atIndex:1];
    [_toolbar setBackgroundColor:[UIColor clearColor]];
    //[_toolbar setAlpha:0.8];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [items addObject:flexibleSpace];
    [items addObject:buttonShare];
    [items addObject:flexibleSpace];
    [items addObject:buttonDesc];
    [items addObject:flexibleSpace];
    [items addObject:buttonFeed];
    [items addObject:flexibleSpace];
    [_toolbar setItems:items animated:NO];
    //[self.view addSubview:_toolbar];
    [self.view bringSubviewToFront:_toolbar];
}

- (IBAction)shareButton_Tap:(id)sender
{
    if (_event.rsvp_status == nil || [_event.rsvp_status isEqualToString:@""] || [_event.rsvp_status isEqualToString:@"not replied"]) {
        
        [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                     title:@"Warning" 
                                    detail:@"Per Facebook policy, you must RSVP to share this event...\nHint: you can RSVP no"
                                     image:[UIImage imageNamed:@"dropdown-alert"]
                                  animated:YES];
        
        return;
    }
    
    controllers_friends_share *shareController = [[controllers_friends_share alloc] initWithUser:[[models_User crtUser] copy] invited:_detailsController.data];
    UINavigationController *shareModal = [[UINavigationController alloc] initWithRootViewController:shareController];
    
    [self presentModalViewController:shareModal animated:YES];
}

- (IBAction)descriptionButton_Tap:(id)sender
{
    controllers_events_Description *descController = [[controllers_events_Description alloc] initWithNibName:@"views_events_Description" bundle:[NSBundle mainBundle] event:[_event copy]];
    UINavigationController *descModal = [[UINavigationController alloc] initWithRootViewController:descController];
    
    [self presentModalViewController:descModal animated:YES];
}

- (IBAction)feedButton_Tap:(id)sender
{
    controllers_events_FeedContainer *feedController = [[controllers_events_FeedContainer alloc] initWithEvent:[_event copy]];
    
    UINavigationController *feedModal = [[UINavigationController alloc] initWithRootViewController:feedController];
    
    [self presentModalViewController:feedModal animated:YES];
}

- (void)cancelAllRequests
{
    [_detailsController cancelAllRequests];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//- (void)setDelegateBack:(id)delegateBack
//{
//    _delegateBack = delegateBack;
//    _detailsController.delegateBack = _delegateBack;
//}
//
//- (void)setSelectorBack:(SEL)selectorBack
//{
//    _selectorBack = selectorBack;
//    _detailsController.selectorBack = _selectorBack;
//}

@end
