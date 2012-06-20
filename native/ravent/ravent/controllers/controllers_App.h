//
//  controllers_App.h
//  ravent
//
//  Created by florian haftman on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "controllers_Login.h"
#import "controllers_SlidingInitial.h"
#import "controllers_TabBar.h"

@interface controllers_App : UIViewController {
    
}

@property (strong, nonatomic) controllers_SlidingInitial *slidingController;
@property (strong, nonatomic) controllers_Login *loginController;

- (void)resetApp;
- (void)flipView;
+ (controllers_App *)instance;

@end
