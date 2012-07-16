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

@implementation controllers_events_Details_Map

@synthesize coordinate;
@synthesize startPoint;
@synthesize endPoint;
@synthesize wayPoints;


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

- (id)initWithEvent:(models_Event *)event
{
    self = [super initWithNibName:@"views_events_Map_Big" bundle:nil];
    
    if (self != nil) {
        
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
    
    
    
    
    @try {
        CLLocationCoordinate2D coord;
        coord.latitude = [_event.latitude floatValue];
        coord.longitude = [_event.longitude floatValue];
        _event.coordinate = coord;
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 0.3*METERS_PER_MILE, 0.3*METERS_PER_MILE);
        
        MKCoordinateRegion adjustedRegion = [_map regionThatFits:region];
        
        [_map setRegion:adjustedRegion animated:YES];
        [_map addAnnotation:_event];
    }
    @catch (NSException *exception) {
        // NOTHING
    }
    @finally {
        // nothing
    }
    
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

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    
    id<MKAnnotation> myAnnotation = [_map.annotations objectAtIndex:0];
    [_map selectAnnotation:myAnnotation animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *identifier = @"MyLocation";   
    
    if ([annotation isKindOfClass:[models_Event class]]) {
        
        models_Event *e = (models_Event *)annotation;
        MKAnnotationView *annotationView = (MKAnnotationView *) [_map dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView == nil) {
            
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:e reuseIdentifier:identifier];
        } else {
            
            annotationView.annotation = e;
        }
        
        annotationView.image = [UIImage imageNamed:@"diamond"];
        [annotationView setFrame:CGRectMake(0, 0, 24, 18)];

        annotationView.canShowCallout = YES;
        
        annotationView.enabled = YES;
        return annotationView;
    }
    
    return nil;
}

- (void)hideAllModal
{
    [_map setShowsUserLocation:NO];
    _map = nil;

    startPoint = nil;
    endPoint = nil;

    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
    _map = nil;
    _segmentedControl = nil;
	startPoint = nil;
	endPoint = nil;
	wayPoints = nil;
	
    _event = nil;
}

@end
