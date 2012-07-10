//
//  controllers_events_Tickets.h
//  ravent
//
//  Created by florian haftman on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface controllers_events_Tickets : UIViewController<UIWebViewDelegate> {
    
    IBOutlet UIWebView *_webview;
    
    NSString *_url;
    
    IBOutlet UIActivityIndicatorView *_spinner;
    IBOutlet UILabel *_errorLabel;
}

- (void)cancelAllRequests;
- (id)initWithURL:(NSString *)url;

@end
