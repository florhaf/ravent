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
    
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
		UIViewController *viewController = [super popViewControllerAnimated:YES];
        UITableViewReloadable *table = (UITableViewReloadable *)viewController;
        
        [table cancelAllRequests];
        
		return viewController;
}

@end
