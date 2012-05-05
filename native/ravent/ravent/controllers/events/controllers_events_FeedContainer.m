//
//  controllers_events_FeedContainer.m
//  ravent
//
//  Created by florian haftman on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_events_FeedContainer.h"

@interface controllers_events_FeedContainer ()

@end

@implementation controllers_events_FeedContainer

- (id)initWithEvent:(models_Event *)event
{
    self = [super initWithNibName:@"views_events_Feed" bundle:nil];
    
    if (self != nil) {
        
        self.title = @"Ravent";
        _feedController = [[controllers_events_Feed alloc] initWithEvent:event];
        _feedController.view.frame = CGRectMake(0, 0, 320, 372);
        [self.view addSubview:_feedController.view];
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
    postController *post = [[postController alloc] initWithNibName:@"views_Post" bundle:nil];
    
    UINavigationController *postModal = [[UINavigationController alloc] initWithRootViewController:post];
    
    [self presentModalViewController:postModal animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hideModal)];        
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)hideModal
{
    [self dismissModalViewControllerAnimated:YES];
    
    [_feedController cancelAllRequests];
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
