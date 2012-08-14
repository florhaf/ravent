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
            
            
            _dragView = [[TKDragView alloc] initWithImage:image
                                               startFrame:startFrame
                                               goodFrames:goodFrames
                                                badFrames:badFrames
                                              andDelegate:self];
            
            
            _dragView.canDragMultipleDragViewsAtOnce = NO;
            _dragView.canUseSameEndFrameManyTimes = YES;
            
            _dragView.canDragFromEndPosition = NO;
            
            [self.dragViews addObject:_dragView];
            
            [[self.view.subviews objectAtIndex:0] addSubview:_dragView];
            
            UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taped:)];
            [g setNumberOfTapsRequired:2];
            [_dragView addGestureRecognizer:g];
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
    _lightBurst = nil;
    _dragView = nil;
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
    
    
}

- (void)dragViewDidEndDragging:(TKDragView *)dragView{
    
}


- (void)dragViewDidEnterStartFrame:(TKDragView *)dragView{
    
}

- (void)dragViewDidLeaveStartFrame:(TKDragView *)dragView{
    
}


- (void)dragViewDidEnterGoodFrame:(TKDragView *)dragView atIndex:(NSInteger)index{
    [_lightBurst setHidden:NO];
}

- (void)dragViewDidLeaveGoodFrame:(TKDragView *)dragView atIndex:(NSInteger)index{    
    [_lightBurst setHidden:YES];
}


- (void)dragViewWillSwapToEndFrame:(TKDragView *)dragView atIndex:(NSInteger)index{
    
    
    
}

- (void)animateLightBurst {
    
    [UIView animateWithDuration:1.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _lightBurst.alpha = (_currentNbOfBurst % 2 == 0) ? 0.7 : 0.5;
                         _lightBurst.transform = CGAffineTransformMakeScale((_currentNbOfBurst % 2 == 0) ? 1 : 0.8, (_currentNbOfBurst % 2 == 0) ? 1 : 0.8);
                     } 
                     completion:^(BOOL finished) {
                         
                         if (_currentNbOfBurst < _maxNbOfBurst) {
                             
                             _currentNbOfBurst++;
                             
                             [self animateLightBurst];
                         }
                     }
     ];
}

- (void)dragViewDidSwapToEndFrame:(TKDragView *)dragView atIndex:(NSInteger)index{
    
    _currentNbOfBurst = 0;
    _maxNbOfBurst = 4;
    
    [self animateLightBurst];
    
    
    [UIView animateWithDuration:1.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _dragView.transform = CGAffineTransformMakeScale(0.6, 0.6);
                     } 
                     completion:^(BOOL finished) {
                         
                     }
     ];
    
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
