//
//  controllers_calendar_Calendar.h
//  ravent
//
//  Created by florian haftman on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "customNavigationController.h"
#import "ECSlidingViewController.h"
#import "controllers_SlidingMenu.h"
#import "Kal.h"
#import "UITableViewReloadable.h"

@interface controllers_calendar_Calendar : UIViewController<UITableViewDelegate> {
    
    UITableViewReloadable *_tableViewController;
    KalViewController *_kal;
    id _datasource;
}

@property (nonatomic, retain) KalViewController *kal;

+ (customNavigationController *)instance;

@end
