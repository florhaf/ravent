//
//  controllers_events_Tickets.m
//  ravent
//
//  Created by florian haftman on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_events_Tickets.h"
#import "models_Event.h"
#import "models_User.h"
#import "GANTracker.h"

@interface controllers_events_Tickets ()

@end

@implementation controllers_events_Tickets

- (void)trackPageView:(NSString *)named forEvent:(NSString *)eid
{
    NSError *error;
    
    if (eid != nil) {
        
        [[GANTracker sharedTracker] setCustomVariableAtIndex:1
                                                        name:@"eid"
                                                       value:eid
                                                   withError:&error];
    }
    
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

- (id)initWithURL:(NSString *)url event:(models_Event *)e
{
    self = [super initWithNibName:@"views_events_Tickets" bundle:nil];
    if (self) {
        // Custom initialization
        
        self.title = @"Gemster";
        _url = url;
        
        [self trackPageView:@"events_details_tickets" forEvent:e.eid];
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
	
    
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:_url];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [_webview loadRequest:requestObj];
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

- (void)dealloc
{
    _errorLabel = nil;
    _webview = nil;
    _url = nil;
}

@end
