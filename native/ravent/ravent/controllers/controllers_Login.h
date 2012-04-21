//
//  controllers_Login.h
//  ravent
//
//  Created by florian haftman on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "models_User.h"

@interface controllers_Login : UIViewController<FBRequestDelegate, FBDialogDelegate, FBSessionDelegate> {
    
    IBOutlet UIImageView *_titleImage;
    IBOutlet UIButton *_loginButton;
    IBOutlet UIActivityIndicatorView *_spinner;
    
    IBOutlet UILabel *_errorLabel;
    
    Facebook *_facebook;
    
    models_User *_user;
}

@property (nonatomic, retain) Facebook *facebook;

- (IBAction)onLoginButtonTap;
- (void)onLogoutButtonTap;

+ (controllers_Login *)instance;

@end
