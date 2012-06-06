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

static controllers_Login *_ctrl;

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
    if (_facebook == nil) {
        
        _facebook = [[Facebook alloc] initWithAppId:@"299292173427947" andDelegate:self];
        _user = [[models_User alloc] initWithDelegate:self andSelector:@selector(onUserLoad:)];
    }
    
    
    if (![_facebook isSessionValid]) {
        
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"offline_access",
                                @"user_events",
                                @"friends_events",
                                @"status_update",
                                @"photo_upload",
                                @"read_stream",
                                @"publish_stream",
                                @"create_event",
                                @"rsvp_event",
                                nil];
        
        [_facebook authorize:permissions];
    } else {
        
        [self fbDidLogin];
    }
}

- (void)onLogoutButtonTap
{
    [_facebook logout];
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
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
    
    [[ActionDispatcher instance] execute:@"onFacebookLogout"];
    
    _facebook.accessToken = nil;
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        
        [storage deleteCookie:cookie];
    }
    
    _facebook = nil;
    _user = nil;
    
    
    
    
    [models_User setCrtUser:nil];
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
    _errorLabel.text = @"";
    
    if (objects == nil || [objects count] == 0) {
        
        _errorLabel.text = @"Google App Engine limit, try again later...";
        [_spinner stopAnimating];
        [_spinner setAlpha:0];
        [_loginButton setEnabled:YES];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"]) {
            [defaults removeObjectForKey:@"FBAccessTokenKey"];
            [defaults removeObjectForKey:@"FBExpirationDateKey"];
            [defaults synchronize];
        }
        
        return;
    }
    
    if ([[objects objectAtIndex:0] isKindOfClass:[NSError class]]) {
        
        NSError *error = [objects objectAtIndex:0];
        _errorLabel.text = error.localizedDescription;
        [_spinner stopAnimating];
        [_spinner setAlpha:0];
        [_loginButton setEnabled:YES];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"]) {
            [defaults removeObjectForKey:@"FBAccessTokenKey"];
            [defaults removeObjectForKey:@"FBExpirationDateKey"];
            [defaults synchronize];
        }
        
        return;
    }
    
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

+ (controllers_Login *)instance
{
    if (_ctrl == nil) {
        
        _ctrl = [[controllers_Login alloc] initWithNibName:@"views_Login" bundle:nil];
    }
    
    return _ctrl;
}

@end
