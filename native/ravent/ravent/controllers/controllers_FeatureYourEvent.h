//
//  controllers_FeatureYourEvent.h
//  ravent
//
//  Created by florian haftman on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "controllers_SlidingMenu.h"
#import "customNavigationController.h"

@interface controllers_FeatureYourEvent : UIViewController<UIWebViewDelegate> {
    
    IBOutlet UIWebView *_webview;
    
    NSString *_url;
    
    IBOutlet UIActivityIndicatorView *_spinner;
    IBOutlet UILabel *_errorLabel;
}

- (void)cancelAllRequests;
+ (customNavigationController *)instance;
+ (void)deleteInstance;


@end
