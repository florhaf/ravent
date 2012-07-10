//
//  controllers_events_Description.m
//  ravent
//
//  Created by florian haftman on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_events_Description.h"

#import "JBAsyncImageView.h"
#import "MBProgressHUD.h"
#import "YRDropdownView.h"
#import "controllers_App.h"
#import "ActionDispatcher.h"
#import "models_User.h"

@implementation controllers_events_Description

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil event:(models_Event *)event
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"Gemster";
        
        //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundLight"]];

        _event = event;
        _event.delegate = self;
        _event.callback = @selector(onLoadDescription:);
    
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        
        [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
        [params setValue:_event.eid forKey:@"eid"];
        
        _url = [@"description" appendQueryParams:params];
        Action *upadteLoadingMessageAction = [[Action alloc] initWithDelegate:self andSelector:@selector(updateLoadingMessageWith:)];
        [[ActionDispatcher instance] add:upadteLoadingMessageAction named:_url];
        [_event loadDescription];
    }
    return self;
}

- (void)updateLoadingMessageWith:(NSString *)text
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    [MBProgressHUD showHUDAddedTo:self.view animated:NO withText:text];
}

- (void)onLoadDescription:(NSArray *)objects
{
    [[ActionDispatcher instance] del:_url];
    
    if ([objects count] > 0) {
        
        id object = [objects objectAtIndex:0];
        
        if ([object isKindOfClass:[NSError class]]) {
            
            NSError *error = (NSError *)object;
            
            [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                         title:@"Error" 
                                        detail:[error localizedDescription]
                                         image:[UIImage imageNamed:@"dropdown-alert"]
                                      animated:YES];
        } else {
            
            _event.description = ((models_Event *)[objects objectAtIndex:0]).description;

            NSString *res = nil;
            
            if (_event.location != nil) {
                
                res = [NSString stringWithFormat:@"%@\n%@\n\n%@", _event.name, _event.location, _event.description];
            } else {
                
                res = [NSString stringWithFormat:@"%@\n\n%@", _event.name, _event.description];
            }
            
            _textView.text = res;
            
//            CGFloat originalHeight = _descriptionLabel.frame.size.height;
//            CGFloat newHeight;
//            
//            _descriptionLabel.text = _event.description;
//            [_descriptionLabel sizeToFit];
//            
//            newHeight = _descriptionLabel.frame.size.height;
//            
//            CGFloat delta = newHeight - originalHeight;
//            
//            if (delta > 0) {
//                
//                _scrollview.contentSize = CGSizeMake(_scrollview.contentSize.width, _scrollview.contentSize.height + delta + _descriptionLabel.frame.origin.y);
//            } 
        }
    } else {
        
        [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                     title:@"Warning" 
                                    detail:@"No result"
                                     image:[UIImage imageNamed:@"dropdown-alert"]
                                  animated:YES];
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *donei = [UIImage imageNamed:@"doneButton"];
    UIButton *doneb = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneb addTarget:self action:@selector(hideModal) forControlEvents:UIControlEventTouchUpInside];
    [doneb setImage:donei forState:UIControlStateNormal];
    [doneb setFrame:CGRectMake(0, 0, donei.size.width, donei.size.height)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithCustomView:doneb];       
    self.navigationItem.rightBarButtonItem = doneButton;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    _tickerItems = [[NSArray alloc] initWithObjects:_event.name, nil];
    [_ticker reloadData];
    
    _labelLocation.text = _event.location;
    _labelAddress.text = _event.location;
}

#pragma mark - Private

- (void)hideModal
{
    [self dismissModalViewControllerAnimated:YES];
    
    if (_event != nil) {
        
        [_event cancelAllRequests];
    }
}

#pragma mark - Ticker delegate

- (UIColor*) backgroundColorForTickerView:(MKTickerView *)vertMenu
{
    return [UIColor clearColor];
}

- (int) numberOfItemsForTickerView:(MKTickerView *)tabView
{
    return [_tickerItems count];
}

- (NSString*) tickerView:(MKTickerView *)tickerView titleForItemAtIndex:(NSUInteger)index
{
    return [_tickerItems objectAtIndex:index];
}

- (NSString*) tickerView:(MKTickerView *)tickerView valueForItemAtIndex:(NSUInteger)index
{
    return nil;
}

- (UIImage*) tickerView:(MKTickerView*) tickerView imageForItemAtIndex:(NSUInteger) index
{
    return nil;
}

- (void)dealloc
{
    _textView = nil;
    _tickerItems = nil;
    
    _ticker = nil;
    _labelLocation = nil;
    _labelAddress = nil;
    
    _event = nil;
    _hud = nil;
    _url = nil;
}

@end
