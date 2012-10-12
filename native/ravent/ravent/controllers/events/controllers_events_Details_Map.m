//
//  controllers_events_Details_Map.m
//  ravent
//
//  Created by florian haftman on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_events_Details_Map.h"
#import "YRDropdownView.h"
#import "controllers_App.h"
#import "models_User.h"
#import "GANTracker.h"
#import "MapSingleton.h"

@implementation controllers_events_Details_Map

@synthesize coordinate;

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

- (id)initWithEvent:(models_Event *)event andParent:(controllers_events_Details *)p
{
    self = [super initWithNibName:@"views_events_Map_Big" bundle:nil];
    
    if (self != nil) {
        
        _parent = p;
        _event = event;
        self.title = @"Gemster";
        
        
        [self trackPageView:@"events_details_map" forEvent:_event.eid];
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *donei = [UIImage imageNamed:@"doneButton"];
    UIButton *doneb = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneb addTarget:self action:@selector(hideAllModal) forControlEvents:UIControlEventTouchUpInside];
    [doneb setImage:donei forState:UIControlStateNormal];
    [doneb setFrame:CGRectMake(0, 0, donei.size.width, donei.size.height)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithCustomView:doneb];       
    self.navigationItem.rightBarButtonItem = doneButton;
    
    _map = [MapSingleton instance].map;
    _map.scrollEnabled = YES;
    _map.zoomEnabled = YES;
    [_map setFrame:CGRectMake(0, 0, 320, 416)];
    [self.view addSubview:_map];
    [self.view sendSubviewToBack:_map];
    
    id<MKAnnotation> myAnnotation = [_map.annotations objectAtIndex:0];
    [_map selectAnnotation:myAnnotation animated:YES];
    
    UIImageView *ivtop = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    [ivtop setImage:[UIImage imageNamed:@"shadowTop"]];
    [self.view addSubview:ivtop];
}

- (IBAction)onDirections_Tap:(id)sender
{
    NSString *slat = _event.latitude;
    NSString *slon = _event.longitude;
    NSString *sAddr = @"http://maps.google.com/maps?saddr=Current%20Location&daddr";
    NSString *sUrl = [NSString stringWithFormat:@"%@=%@,%@", sAddr, slat, slon];
    
    NSURL *uUrl = [NSURL URLWithString:sUrl];

    UIApplication *app = [UIApplication sharedApplication];
    
    
    [app openURL:uUrl];  
}

- (void)hideAllModal
{
    [self dismissModalViewControllerAnimated:YES];
    
    [self performSelector:@selector(mydealloc) withObject:nil afterDelay:0.5];
}

- (void)mydealloc
{
    self.navigationItem.rightBarButtonItem = nil;
    
    // map dealloc
    id<MKAnnotation> myAnnotation = [_map.annotations objectAtIndex:0];
    [_map deselectAnnotation:myAnnotation animated:NO];
    [_map removeFromSuperview];
    _map = nil;
    [_parent setMapOnTop];
    
    _parent = nil;
    _segmentedControl = nil;

	if (_event) {
        
        [_event mydealloc];
        _event = nil;
    }
}

@end
