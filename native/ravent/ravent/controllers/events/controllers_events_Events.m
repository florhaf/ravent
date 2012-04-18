//
//  controllers_events_Events.m
//  ravent
//
//  Created by florian haftman on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_events_Events.h"
#import "YRDropdownView.h"
#import "controllers_events_List_p2p.h"
#import "controllers_events_Details.h"
#import "controllers_events_Options_p2p.h"

@implementation controllers_events_Events

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forUser:(models_User *)user
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        _user = user;
        self.title = @"Ravent";
    }
    return self;
}

- (void)flipView {
    
    UIView *mapView = _mapController.view;
    UIView *listView = _listController.view;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.8];
    [UIView setAnimationTransition:[mapView superview] ? UIViewAnimationTransitionCurlUp : UIViewAnimationTransitionCurlDown

                           forView:self.view cache:YES];
	
	if ([mapView superview]) {
        
		[mapView removeFromSuperview];
		[self.view addSubview:listView];
        self.navigationItem.rightBarButtonItem.title = @"Map";
    } else {
        
		[listView removeFromSuperview];
		[self.view addSubview:mapView];
        self.navigationItem.rightBarButtonItem.title = @"List";
    }
    
	[UIView commitAnimations];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mapController = [[controllers_events_Map_p2p alloc] initWithNibName:@"views_events_Map" bundle:nil user:[_user copy]];
    _listController = [[controllers_events_List_p2p alloc] initWithUser:[_user copy]];
    _listController.view.frame = CGRectMake(0, 0, _listController.view.frame.size.width, _listController.view.frame.size.height);
    
    [self addChildViewController:_mapController];
    [self addChildViewController:_listController];
    [self.view addSubview:_listController.view];
    
    UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(flipView)];          
    self.navigationItem.rightBarButtonItem = mapButton;
    
    UIBarButtonItem *optionsButton = [[UIBarButtonItem alloc] initWithTitle:@"Opt" style:UIBarButtonItemStylePlain target:self action:@selector(showOptionsModal)];          
    self.navigationItem.leftBarButtonItem = optionsButton;
}

- (void)showOptionsModal
{
    controllers_events_Options_p2p *options = [[controllers_events_Options_p2p alloc] initWithNibName:@"views_events_Options" bundle:nil];
    UINavigationController *optionsModal = [[UINavigationController alloc] initWithRootViewController:options];
    
    [self presentModalViewController:optionsModal animated:YES];
}

@end
