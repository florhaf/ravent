//
//  controllers_FeatureYourEvent.m
//  ravent
//
//  Created by florian haftman on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_FeatureYourEvent.h"
#import "models_User.h"
#import "GANTracker.h"

@interface controllers_FeatureYourEvent ()

@end

@implementation controllers_FeatureYourEvent

static customNavigationController *_ctrl;

- (void)trackPageView:(NSString *)named
{
    NSError *error;
    
    
    [[GANTracker sharedTracker] setCustomVariableAtIndex:2
                                                    name:@"uid"
                                                   value:[models_User crtUser].uid
                                               withError:&error];
    
    [[GANTracker sharedTracker] setCustomVariableAtIndex:3
                                                    name:@"app_version"
                                                   value:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
                                               withError:&error];
    
    [[GANTracker sharedTracker] trackPageview:named
                                    withError:&error];
}

- (id)init
{
    self = [super initWithNibName:@"views_FeatureYourEvent" bundle:nil];
    if (self) {
        // Custom initialization
        
        self.title = @"Gemster";
        _url = @"http://promoter.gemsterapp.com/index.html";
        
        [self trackPageView:@"events_featureYourEvent"];
    }
    return self;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_spinner stopAnimating];
    [_spinner setHidden:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_spinner stopAnimating];
    [_spinner setHidden:YES];
    
    _errorLabel.text = @"URL mal formed...";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.title = @"Gemster";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // TOLBAR BUTTONS
    UIImage *menubg = [UIImage imageNamed:@"navBarBG"];
    UIImage *menui = [UIImage imageNamed:@"navBarMenu"];
    
    UIButton *menub = [UIButton buttonWithType:UIButtonTypeCustom];
    [menub addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    [menub setImage:menui forState:UIControlStateNormal];
    [menub setBackgroundImage:menubg forState:UIControlStateNormal];
    [menub setFrame:CGRectMake(0, 0, 40, 29)];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:menub];
    self.navigationItem.leftBarButtonItem = menuButton;
	
    
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:_url];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [_webview loadRequest:requestObj];
    
    // shadows
    UIImageView *ivleft = [[UIImageView alloc] initWithFrame:CGRectMake(-40, 0, 40, 460)];
    [ivleft setImage:[UIImage imageNamed:@"shadowLeft"]];
    [self.slidingViewController.topViewController.view addSubview:ivleft];
    
    UIImageView *ivtop = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    [ivtop setImage:[UIImage imageNamed:@"shadowTop"]];
    [self.view addSubview:ivtop];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[controllers_SlidingMenu class]]) {
        self.slidingViewController.underLeftViewController  = [controllers_SlidingMenu instance];
    }
    
    if (self.slidingViewController.underRightViewController != nil) {
        self.slidingViewController.underRightViewController = nil;
    }
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.slidingViewController.topViewController.view removeGestureRecognizer:[self.slidingViewController panGesture]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)cancelAllRequests
{
    
}

- (void)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}


- (void)dealloc
{
    _errorLabel = nil;
    _webview = nil;
    _url = nil;
}

+ (customNavigationController *)instance 
{
    if (_ctrl == nil) {
        
        controllers_FeatureYourEvent *feature = [[controllers_FeatureYourEvent alloc] init];
        _ctrl = [[customNavigationController alloc] initWithRootViewController:feature];
    }
    
    return _ctrl;
}

+ (void)deleteInstance
{
    _ctrl = nil;
}

@end
