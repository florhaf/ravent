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
#import "TKDragView.h"
#import "models_User.h"

@interface controllers_TakeTheTour ()

@end

@implementation controllers_TakeTheTour

@synthesize next = _next;
@synthesize container = _container;

@synthesize dragViews = dragViews_;
@synthesize goodFrames =goodFrames_;
@synthesize badFrames = badFrames_;
@synthesize canDragMultipleViewsAtOnce =canDragMultipleViewsAtOnce_;
@synthesize canUseTheSameFrameManyTimes =canUseTheSameFrameManyTimes_;

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
    
    [models_User crtUser].isTourTaken = YES;
    [[models_User crtUser] saveToNSUserDefaults];
    
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

- (void)loadDropAGem
{
        NSBundle *bundle = [NSBundle mainBundle];
        
        NSString *path = [bundle pathForResource:@"diamond.png" ofType:nil];
        
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        
        
        self.goodFrames = [NSMutableArray arrayWithCapacity:1];
        self.badFrames = [NSMutableArray arrayWithCapacity:0];
        
        NSMutableArray *goodFrames = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray *badFrames = [NSMutableArray arrayWithCapacity:0];
        self.dragViews = [NSMutableArray arrayWithCapacity:1];
        
        for (int i = 0; i< 1; i++) {
            
            
            CGRect endFrame =   CGRectMake(846, 205, 100, 90);
            
            CGRect badFrame =   CGRectMake(0, 0, 0, 0);
            
            [goodFrames addObject:TKCGRectValue(endFrame)];
            [badFrames addObject:TKCGRectValue(badFrame)];
            
            UIView *endView = [[UIView alloc] initWithFrame:endFrame];
            
            [self.view addSubview:endView];
            
            [self.goodFrames addObject:endView];
            
            UIView *badView = [[UIView alloc] initWithFrame:badFrame];
            [self.view addSubview:badView];
            
            [self.badFrames addObject:badView];
        }
        
        self.canUseTheSameFrameManyTimes = YES;
        self.canDragMultipleViewsAtOnce = NO;
        
        
        
        for (int i = 0; i< 1; i++) {
            
            CGRect startFrame = CGRectMake(670, 225, 60, 50);
            
            
            TKDragView *dragView = [[TKDragView alloc] initWithImage:image
                                               startFrame:startFrame
                                               goodFrames:goodFrames
                                                badFrames:badFrames
                                              andDelegate:self];
            
            
            dragView.canDragMultipleDragViewsAtOnce = NO;
            dragView.canUseSameEndFrameManyTimes = YES;
            
            dragView.canDragFromEndPosition = NO;
            
            [self.dragViews addObject:dragView];
            
            [[self.view.subviews objectAtIndex:0] addSubview:dragView];
            
            UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taped:)];
            [g setNumberOfTapsRequired:2];
            [dragView addGestureRecognizer:g];
        }
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [_next setEnabled:NO];
    
    
    [self loadDropAGem];
    
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


#pragma mark - TKDragViewDelegate

- (void)dragViewDidStartDragging:(TKDragView *)dragView{
    
    [UIView animateWithDuration:0.2 animations:^{
        dragView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    }];
}

- (void)dragViewDidEndDragging:(TKDragView *)dragView{
    
    [UIView animateWithDuration:0.2 animations:^{
        dragView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
}


- (void)dragViewDidEnterStartFrame:(TKDragView *)dragView{
    
    [UIView animateWithDuration:0.2 animations:^{
        dragView.alpha = 0.5;
    }];
}

- (void)dragViewDidLeaveStartFrame:(TKDragView *)dragView{
    
    [UIView animateWithDuration:0.2 animations:^{
        dragView.alpha = 1.0;
    }];
}

- (void)dragViewDidEnterGoodFrame:(TKDragView *)dragView atIndex:(NSInteger)index
{
    [UIView animateWithDuration:0.2 animations:^{
        dragView.alpha = 0.5;
    }];
}


- (void)dragViewWillSwapToEndFrame:(TKDragView *)dragView atIndex:(NSInteger)index{
    
    
    
}

- (void)dragViewDidSwapToEndFrame:(TKDragView *)dragView atIndex:(NSInteger)index{
    
    [UIView animateWithDuration:0.4
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         dragView.transform = CGAffineTransformMakeRotation(M_PI);
                     } 
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.4
                                               delay:0.1
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              dragView.transform = CGAffineTransformMakeRotation(2 * M_PI);
                                          } 
                                          completion:^(BOOL finished) {
                                              
                                              [dragView setFrame:CGRectMake(0, 0, 0, 0)];
                                          }];
                     }];
    
    [_next setEnabled:YES];
}


- (void)dragViewWillSwapToStartFrame:(TKDragView *)dragView{
    [UIView animateWithDuration:0.2 animations:^{
        dragView.alpha = 1.0f; 
    }];
}

- (void)dragViewDidSwapToStartFrame:(TKDragView *)dragView{
    
}

@end
