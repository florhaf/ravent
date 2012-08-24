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

@interface controllers_Login : UIViewController
<FBRequestDelegate,
FBDialogDelegate,
FBSessionDelegate>{
    NSArray *permissions;
    
    IBOutlet UILabel *_nameLabel;
    IBOutlet UIButton *_loginButton;
    IBOutlet UIActivityIndicatorView *_spinner;
    IBOutlet UILabel *_errorLabel;
    
    NSTimer *_loginTimer;
    
    models_User *_user;
    models_User *_userLoader;
}

@property (nonatomic, retain) NSArray *permissions;


- (IBAction)onLoginButtonTap:(id)sender;


+ (controllers_Login *)instance;

@end