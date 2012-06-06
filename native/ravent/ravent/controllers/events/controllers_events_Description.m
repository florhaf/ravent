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

@implementation controllers_events_Description

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil event:(models_Event *)event
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"Ravent";
        
        //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundLight"]];

        _event = event;
        _event.delegate = self;
        _event.callback = @selector(onLoadDescription:);
    
        
        [_event loadDescription];
    }
    return self;
}

- (void)onLoadDescription:(NSArray *)objects
{
    if ([objects count] > 0) {
        
        id object = [objects objectAtIndex:0];
        
        if ([object isKindOfClass:[NSError class]]) {
            
            NSError *error = (NSError *)object;
            
            [YRDropdownView showDropdownInView:self.view 
                                         title:@"Error" 
                                        detail:[error localizedDescription]
                                         image:[UIImage imageNamed:@"dropdown-alert"]
                                      animated:YES];
        } else {
            
            _event.description = ((models_Event *)[objects objectAtIndex:0]).description;

            
            NSString *res = [NSString stringWithFormat:@"%@\n%@\n\n%@", _event.name, _event.location, _event.description];
            
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
        
        [YRDropdownView showDropdownInView:self.view 
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
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

#pragma mark - Private

- (void)hideModal
{
    [self dismissModalViewControllerAnimated:YES];
    
    if (_event != nil) {
        
        [_event cancelAllRequests];
    }
}

@end
