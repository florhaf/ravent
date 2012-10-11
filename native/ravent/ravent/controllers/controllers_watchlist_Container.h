//
//  controllers_watchlist_Container.h
//  ravent
//
//  Created by florian haftman on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "models_User.h"

#import <QuartzCore/QuartzCore.h>
#import "ECSlidingViewController.h"
#import "controllers_SlidingMenu.h"
#import "customNavigationController.h"
#import "controllers_watchlist_WatchList.h"

@interface controllers_watchlist_Container : UIViewController {
    
    controllers_watchlist_WatchList *_listController;

    
    models_User *_user;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forUser:(models_User *)user;

- (void)revealMenu:(id)sender;

+ (customNavigationController *)instance;
+ (void)release;
@end
