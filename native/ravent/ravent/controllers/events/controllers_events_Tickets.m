//
//  controllers_events_Tickets.m
//  ravent
//
//  Created by florian haftman on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_events_Tickets.h"

@interface controllers_events_Tickets ()

@end

@implementation controllers_events_Tickets

- (id)initWithURL:(NSString *)url
{
    self = [super initWithNibName:@"views_events_Tickets" bundle:nil];
    if (self) {
        // Custom initialization
        
        self.title = @"Gemster";
        _url = url;
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
