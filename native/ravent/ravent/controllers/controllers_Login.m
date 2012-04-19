//
//  controllers_Login.m
//  ravent
//
//  Created by florian haftman on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_Login.h"
#import "ActionDispatcher.h"

@implementation controllers_Login

@synthesize facebook = _facebook;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
                
        _facebook = [[Facebook alloc] initWithAppId:@"299292173427947" andDelegate:self];
        _user = [[models_User alloc] initWithDelegate:self andSelector:@selector(onUserLoad:)];
        
        // should be at the controllers_App level
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        if ([defaults objectForKey:@"FBAccessTokenKey"] 
//            && [defaults objectForKey:@"FBExpirationDateKey"]) {
//            _facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
//            _facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
//        }
    }
    return self;
}

- (IBAction)onLoginButtonTap
{
    if (![_facebook isSessionValid]) {
        [_facebook authorize:nil];
    }
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    NSLog(@"didnotloggedin");
}

- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt
{
    
}

- (void)fbDidLogout
{
    
}

- (void)fbSessionInvalidated
{
    
}

// Pre iOS 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    return [_facebook handleOpenURL:url]; 
}

// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return [_facebook handleOpenURL:url]; 
}

- (void)fbDidLogin {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_facebook.accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:_facebook.expirationDate forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    _user.accessToken = _facebook.accessToken;
    
    [_loginButton setEnabled:NO];
    [_spinner setAlpha:1];
    [_spinner startAnimating];
    
    [_facebook requestWithGraphPath:@"/me?fields=id" andDelegate:self];
}

- (void)request:(FBRequest*)request didLoad:(id)result
{
    NSString* uid = [result objectForKey:@"id"];

    _user.uid = uid;
    
    [_user loadUser];
}

- (void)onUserLoad:(NSArray *)objects
{
    models_User *user = [objects objectAtIndex:0];
    
    [models_User setCrtUser:user];
    [models_User crtUser].accessToken = _user.accessToken;
    
    [[ActionDispatcher instance] execute:@"onFacebookLogin"];
    
    [_loginButton setEnabled:YES];
    [_spinner setAlpha:0];
    [_spinner stopAnimating];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    _titleImage.frame = CGRectMake(_titleImage.frame.origin.x, 90, _titleImage.frame.size.width, _titleImage.frame.size.height);
    
	[UIView commitAnimations];

    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
    [UIView setAnimationDelay:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    _loginButton.alpha = 1;
    
	[UIView commitAnimations];
}

@end
