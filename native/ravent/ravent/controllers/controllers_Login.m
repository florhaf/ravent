#import "controllers_Login.h"
#import "AppDelegate.h"
#import "FBConnect.h"
#import "ActionDispatcher.h"

@implementation controllers_Login

@synthesize permissions;

static controllers_Login *_ctrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    
    if (self != nil) {
        
        permissions = [[NSArray alloc] initWithObjects:
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
        _user = [[models_User alloc] initWithDelegate:self andSelector:@selector(onUserLoad:)];
    }
    
    return self;
}

- (void)dealloc {
    
    
}

#pragma mark - Facebook API Calls
/**
 * Make a Graph API Call to get information about the current logged in user.
 */
- (void)apiFQLIMe {
    
    _errorLabel.text = [NSString stringWithFormat:@"%@\nGetting your Facebook id...",_errorLabel.text];
    
    // Using the "pic" picture since this currently has a maximum width of 100 pixels
    // and since the minimum profile picture size is 180 pixels wide we should be able
    // to get a 100 pixel wide version of the profile picture
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"SELECT uid FROM user WHERE uid=me()", @"query",
                                   nil];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[delegate facebook] requestWithMethodName:@"fql.query"
                                     andParams:params
                                 andHttpMethod:@"POST"
                                   andDelegate:self];
}

- (void)apiGraphUserPermissions {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[delegate facebook] requestWithGraphPath:@"me/permissions" andDelegate:self];
}


#pragma - Private Helper Methods

/**
 * Show the authorization dialog.
 */
- (IBAction)onLoginButtonTap:(id)sender {
    
    [_loginButton setEnabled:NO];
    [_spinner setAlpha:1];
    [_spinner startAnimating];
    
    _errorLabel.text = @"Connecting to Facebook...";
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![[delegate facebook] isSessionValid]) {
        [[delegate facebook] authorize:permissions];
    } else {
        [self apiFQLIMe];
    }
}

/**
 * Invalidate the access token and clear the cookie.
 */
- (void)onLogoutButtonTap {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[delegate facebook] logout];
    
    _nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, 90, _nameLabel.frame.size.width, _nameLabel.frame.size.height);
    
    _loginButton.alpha = 1;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //if (![[delegate facebook] isSessionValid]) {
      
    
    if ([delegate facebook].accessToken != nil && ![[delegate facebook].accessToken isEqualToString:@""]) {
        
        [_loginButton setEnabled:NO];
        [_spinner setAlpha:1];
        [_spinner startAnimating];
        [self apiFQLIMe];
    } else {
        
        [self moveNameUp];   
    }
    //}
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    //[self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - store

- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

#pragma mark - FBSessionDelegate Methods
/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
    
    _errorLabel.text = [NSString stringWithFormat:@"%@\nLogged in Facebook",_errorLabel.text];
    
    [self apiFQLIMe];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self storeAuthData:[[delegate facebook] accessToken] expiresAt:[[delegate facebook] expirationDate]];
    
//    [pendingApiCallsController userDidGrantPermission];
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {

    [self storeAuthData:accessToken expiresAt:expiresAt];
    [models_User crtUser].accessToken = accessToken;
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
//    [pendingApiCallsController userDidNotGrantPermission];
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
//    pendingApiCallsController = nil;
    
    _errorLabel.text = @"";
    
    // Remove saved authorization information if it exists and it is
    // ok to clear it (logout, session invalid, app unauthorized)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    
    [self performSelector:@selector(moveNameUp) withObject:nil afterDelay:0.5];
    
    [[ActionDispatcher instance] execute:@"onFacebookLogout"];
}

/**
 * Called when the session has expired.
 */
- (void)fbSessionInvalidated {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Auth Exception"
                              message:@"Your session has expired."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil,
                              nil];
    [alertView show];

    [self fbDidLogout];
    
    [self moveNameUp];
}

#pragma mark - FBRequestDelegate Methods

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array or a string, depending
 * on the format of the API response. If you need access to the raw response,
 * use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
    
    if ([result isKindOfClass:[NSArray class]]) {
        result = [result objectAtIndex:0];
    }
    
    if ([result objectForKey:@"uid"]) {
        
        _errorLabel.text = [NSString stringWithFormat:@"%@\nGetting your profile on Gemster...",_errorLabel.text];
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString* uid = [result objectForKey:@"uid"];
        
        _user.accessToken = [[delegate facebook] accessToken];
         _user.uid = uid;
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        
        [params setValue:_user.accessToken forKey:@"access_token"];
        [params setValue:_user.uid forKey:@"userID"];
        _userLoader = [[models_User alloc] init];
        
        [_userLoader loadAllWithParams:params force:YES];
        [_user loadUser];
        
       
    } else {
        
    _errorLabel.text = [NSString stringWithFormat:@"%@\nError getting your Facebook id\nTry again",_errorLabel.text];
        [_loginButton setEnabled:YES];
        [_spinner setAlpha:0];
        [_spinner stopAnimating];
    }
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Err message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    NSLog(@"Err code: %d", [error code]);
}



#pragma flo stuff

- (void)onUserLoad:(NSArray *)objects
{
    _errorLabel.text = [NSString stringWithFormat:@"%@\nLaunching...",_errorLabel.text];
    
    if (objects == nil || [objects count] == 0) {
        
        _errorLabel.text = [NSString stringWithFormat:@"%@\nGoogle App Engine limit, try again later...",_errorLabel.text];
        [_spinner stopAnimating];
        [_spinner setAlpha:0];
        [_loginButton setEnabled:YES];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"]) {
            [defaults removeObjectForKey:@"FBAccessTokenKey"];
            [defaults removeObjectForKey:@"FBExpirationDateKey"];
            [defaults synchronize];
            
            [[models_User crtUser] delFromNSUserDefaults];
        }
        
        return;
    }
    
    if ([[objects objectAtIndex:0] isKindOfClass:[NSError class]]) {
        
        NSError *error = [objects objectAtIndex:0];
        _errorLabel.text = [NSString stringWithFormat:@"%@\n%@, try again later...",_errorLabel.text, error.localizedDescription];
        [_spinner stopAnimating];
        [_spinner setAlpha:0];
        [_loginButton setEnabled:YES];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"]) {
            [defaults removeObjectForKey:@"FBAccessTokenKey"];
            [defaults removeObjectForKey:@"FBExpirationDateKey"];
            [defaults synchronize];
            
            [[models_User crtUser] delFromNSUserDefaults];
        }
        
        return;
    }
    
    models_User *user = [objects objectAtIndex:0];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [models_User setCrtUser:user];
    [models_User crtUser].accessToken = [delegate facebook].accessToken;
    [[models_User crtUser] saveToNSUserDefaults];
    
    [self performSelector:@selector(onFacebookLogin) withObject:nil afterDelay:1];
}

- (void) onFacebookLogin
{
    [[ActionDispatcher instance] execute:@"onFacebookLogin"];
    
    [_loginButton setEnabled:YES];
    [_spinner setAlpha:0];
    [_spinner stopAnimating];
}

- (void)moveNameUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    _nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, 90, _nameLabel.frame.size.width, _nameLabel.frame.size.height);
    
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