//
//  customNavigationController.h
//  ravent
//
//  Created by florian haftman on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface customNavigationController : UINavigationController <UINavigationControllerDelegate>

@property (nonatomic, retain) UIViewController *rootController;

- (id)initWithRootViewController:(UIViewController *)rootViewController translucnet:(BOOL)value;

@end
