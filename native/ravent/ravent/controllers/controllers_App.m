//
//  controllers_App.m
//  ravent
//
//  Created by florian haftman on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_App.h"
#import "ActionDispatcher.h"
#import "controllers_events_Events.h"

@implementation controllers_App

@synthesize loginController = _loginController;
@synthesize slidingController = _slidingController;

static controllers_App *_ctrl;

- (id)init
{
    self = [super init];
    
    if (self) {
            
        Action *loginAction = [[Action alloc] initWithDelegate:self andSelector:@selector(flipView)];
        Action *logoutAction = [[Action alloc] initWithDelegate:self andSelector:@selector(flipView)];
        
        [[ActionDispatcher instance] add:loginAction named:@"onFacebookLogin"];
        [[ActionDispatcher instance] add:logoutAction named:@"onFacebookLogout"];
        
        [self.view addSubview:[controllers_Login instance].view];
        
        
        
        _ctrl = self;
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

- (void)flipView
{
    
    if (_slidingController == nil) {
            
        _slidingController = [[controllers_SlidingInitial alloc] init];
        _slidingController.view.frame = CGRectMake(0, 0, _slidingController.view.frame.size.width, _slidingController.view.frame.size.height);
    }    
    
    
    
    
    UIView *slide = _slidingController.view;
    UIView *login = _loginController.view;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.8];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
	
	if ([slide superview]) {
        
		[slide removeFromSuperview];
		[self.view addSubview:login];
        
        [self resetApp];
    } else {
        
        [UIView setAnimationDelay:1.2];
        
		[login removeFromSuperview];
        login = nil;
		[self.view addSubview:slide];
    }
    
	[UIView commitAnimations];
}

- (void)resetApp
{
    [controllers_events_Events deleteInstance];
    _slidingController = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor blackColor]];
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

+ (controllers_App *)instance
{
    return _ctrl;
}

@end
