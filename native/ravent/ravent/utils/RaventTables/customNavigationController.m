//
//  customNavigationController.m
//  ravent
//
//  Created by florian haftman on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "customNavigationController.h"
#import "UITableViewReloadable.h"


@implementation UINavigationBar (CustomBackground)

- (void)drawRect:(CGRect)rect
{
    UIImage *navBackgroundImage = [[UIImage imageNamed:@"navBar"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
    [navBackgroundImage drawInRect:rect];
}

@end

@implementation customNavigationController
    
@synthesize rootController = _rootController;

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    
    if (self) {
        
        // ios5 check
        if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
            [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed: @"grayNavbar"] forBarMetrics:UIBarMetricsDefault];
        }
        
        
        
        _rootController = rootViewController;
    }
    
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController translucnet:(BOOL)value
{
    self = [super initWithRootViewController:rootViewController];
    
    if (self) {
        
        //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
        _rootController = rootViewController;
        
        self.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        self.navigationController.wantsFullScreenLayout = value;
    }
    
    return self;
}

- (void)viewDidLoad
{
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(revealMenu:)];         
    
    self.navigationItem.leftBarButtonItem = menuButton;
    
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
		UIViewController *viewController = [super popViewControllerAnimated:YES];
        UITableViewReloadable *table = (UITableViewReloadable *)viewController;
        
        [table cancelAllRequests];
        self.navigationBar.barStyle = UIBarStyleDefault;
        self.navigationBar.alpha = 1;
        
		return viewController;
}

@end
