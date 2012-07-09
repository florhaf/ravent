//
//  controllers_SlidingMenu.h
//  ravent
//
//  Created by florian haftman on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"

@interface controllers_SlidingMenu : UIViewController<UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate> {
    
    UIViewController *_jiraConnect;
}

@property (nonatomic, strong) NSArray *menuItems;

+ (controllers_SlidingMenu *)instance;
+ (void)deleteInstance;

@end
