//
//  controllers_dropagem_DropAGemViewController.h
//  ravent
//
//  Created by florian haftman on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "controllers_dropagem_List.h"
#import "models_User.h"

#import <QuartzCore/QuartzCore.h>
#import "ECSlidingViewController.h"
#import "controllers_SlidingMenu.h"
#import "customNavigationController.h"

@interface controllers_dropagem_DropAGemViewController : UIViewController {
    
    
    controllers_dropagem_List *_listController;
    
    IBOutlet UIToolbar *_toolbar;
    IBOutlet UISegmentedControl *_seg;
    
    models_User *_user;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forUser:(models_User *)user;

- (void)revealMenu:(id)sender;

+ (customNavigationController *)instance;
+ (void)release;

@end
