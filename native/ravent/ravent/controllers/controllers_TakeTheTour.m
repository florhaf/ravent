//
//  controllers_TakeTheTour.m
//  ravent
//
//  Created by florian haftman on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_TakeTheTour.h"
#import "UIView+Animation.h"
#import "customNavigationController.h"

@interface controllers_TakeTheTour ()

@end

@implementation controllers_TakeTheTour

@synthesize next = _next;
@synthesize container = _container;

static customNavigationController *_ctrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.title = @"Gemster";
    }
    return self;
}

- (IBAction)next:(id)sender
{
    CGFloat crtX = _container.frame.origin.x;
    
    [_container raceTo:CGPointMake(crtX - 320, 0) withSnapBack:YES];
}

- (IBAction)no:(id)sender
{
    self.title = @"";
    
    
    [UIView animateWithDuration:1 animations:^(void) {
        
        [self.view setAlpha:0];
        [_ctrl.navigationBar setAlpha:0];
    } completion:^(BOOL finished) {
        
        [self.view removeFromSuperview];
        [_ctrl.view removeFromSuperview];
        
        [_ctrl removeFromParentViewController];
        [self removeFromParentViewController];
        
        
        
        _ctrl.navigationBarHidden = YES;
        
        [controllers_TakeTheTour deleteInstance];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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

- (void)dealloc
{
    _container = nil;
    _next = nil;
    _ctrl = nil;
}

+ (customNavigationController *)instance
{
    if (_ctrl == nil) {
        
        controllers_TakeTheTour *tour = [[controllers_TakeTheTour alloc] initWithNibName:@"views_TakeTheTour" bundle:nil];
        _ctrl = [[customNavigationController alloc] initWithRootViewController:tour];
        
        tour = nil;
    }
    
    return _ctrl;
}

+ (void)deleteInstance
{
    //_ctrl.container = nil;
    
    
    [_ctrl setRootController:nil];
    _ctrl = nil;
}

@end
