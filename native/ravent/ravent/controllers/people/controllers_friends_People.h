//
//  controllers_friends_People.h
//  ravent
//
//  Created by florian haftman on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "controllers_friends_Following.h"
#import "customNavigationController.h"

#import <QuartzCore/QuartzCore.h>
#import "ECSlidingViewController.h"
#import "controllers_SlidingMenu.h"

@interface controllers_friends_People : UIViewController {
    
    models_User *_user;
    
    controllers_friends_Following *_following;
    controllers_friends_Following *_followers;
    controllers_friends_Following *_currentVisible;
    
    IBOutlet UIView *_header;
    IBOutlet UILabel *_headerNameLabel;
    IBOutlet UILabel *_headerFollowingLabel;
    IBOutlet UILabel *_headerFollowersLabel;
    IBOutlet UILabel *_headerEventsLabel;
    IBOutlet JBAsyncImageView *_headerImage;
    
    IBOutlet UISegmentedControl *_segmentedControl;
    IBOutlet UIView *_container;
    
    BOOL _isFollowersVisible;
}

- (id)initWithUser:(models_User *)user;
- (void)loadData;
- (void)onCrtUserLoad:(NSArray *)objects;
- (void)onMeTap;
- (void)revealMenu:(id)sender;
- (void)revealAll:(id)sender;

- (IBAction)onSegmentedControlValueChanged;

- (void)uiview:(UIView *)uiview raceTo:(CGPoint)destination withSnapBack:(BOOL)withSnapBack;

+ (customNavigationController *)instance;

@end
