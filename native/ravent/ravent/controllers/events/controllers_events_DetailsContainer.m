//
//  controllers_events_DetailsContainer.m
//  ravent
//
//  Created by florian haftman on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_events_DetailsContainer.h"

@interface controllers_events_DetailsContainer ()

@end

@implementation controllers_events_DetailsContainer

- (id)initWithEvent:(models_Event *)event
{
    self = [super initWithNibName:@"views_events_Details_Container" bundle:nil];
    
    if (self != nil) {
        
        self.title = @"Ravent";
        _event = event;
        _detailsController = [[controllers_events_Details alloc] initWithEvent:event];
        _detailsController.view.frame = CGRectMake(0, 0, 320, 460);
        [self.view addSubview:_detailsController.view];
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
    
//    UIImageView *buttonCalView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"buttonCal"]];
//    UIImageView *buttonShareView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"buttonShare"]];
//    UIImageView *buttonDescView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"buttonDesc"]];
//    UIImageView *buttonFeedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"buttonFeed"]];
//    
//    buttonCalView.frame = CGRectMake(0, 0, 68, 32);
//    buttonShareView.frame = CGRectMake(0, 0, 68, 32);
//    buttonDescView.frame = CGRectMake(0, 0, 68, 32);
//    buttonFeedView.frame = CGRectMake(0, 0, 68, 32);
//    
//    UIBarButtonItem *buttonCal = [[UIBarButtonItem alloc] initWithCustomView:buttonCalView];
//    UIBarButtonItem *buttonShare = [[UIBarButtonItem alloc] initWithCustomView:buttonShareView];
//    UIBarButtonItem *buttonDesc = [[UIBarButtonItem alloc] initWithCustomView:buttonDescView];
//    UIBarButtonItem *buttonFeed = [[UIBarButtonItem alloc] initWithCustomView:buttonFeedView];
//    
//    [buttonCal setWidth:buttonCalView.frame.size.width];
//    [buttonShare setWidth:buttonShareView.frame.size.width];
//    [buttonDesc setWidth:buttonDescView.frame.size.width];
//    [buttonFeed setWidth:buttonFeedView.frame.size.width];
//    
//    [_toolbar insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toolbar"]] atIndex:1];
//    
//    NSMutableArray *items = [[NSMutableArray alloc] init];
//    [items addObject:buttonCal];
//    [items addObject:buttonShare];
//    [items addObject:buttonDesc];
//    [items addObject:buttonFeed];
//    [_toolbar setItems:items animated:NO];
//    [self.view addSubview:_toolbar];
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



@end
