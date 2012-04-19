//
//  customNavigationController.m
//  ravent
//
//  Created by florian haftman on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "customNavigationController.h"
#import "UITableViewReloadable.h"

@implementation customNavigationController
    
- (id) initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    
    if (self) {
        
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    }
    
    return self;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
		UIViewController *viewController = [super popViewControllerAnimated:YES];
        UITableViewReloadable *table = (UITableViewReloadable *)viewController;
        
        [table cancelAllRequests];
        
		return viewController;
}

@end
