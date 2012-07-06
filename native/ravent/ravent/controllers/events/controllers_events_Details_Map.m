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
#import "UICRouteOverlayMapView.h"
#import "UICRouteAnnotation.h"

@implementation controllers_events_Details_Map

@synthesize coordinate;
@synthesize startPoint;
@synthesize endPoint;
@synthesize wayPoints;
@synthesize travelMode;

- (id)initWithEvent:(models_Event *)event
{
    self = [super initWithNibName:@"views_events_Map_Big" bundle:nil];
    
    if (self != nil) {
        
        _event = event;
        self.title = @"Gemster";
        
        
        
    }
    
    return self;
}

#pragma mark <UICGDirectionsDelegate> Methods

- (void)directionsDidFinishInitialize:(UICGDirections *)directions {
	[self update];
}

- (void)directions:(UICGDirections *)directions didFailInitializeWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Map Directions" message:[error localizedFailureReason] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alertView show];
}

- (void)directionsDidUpdateDirections:(UICGDirections *)directions {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	// Overlay polylines
	UICGPolyline *polyline = [directions polyline];
	NSArray *routePoints = [polyline routePoints];
	[routeOverlayView setRoutes:routePoints];
	
	// Add annotations
	UICRouteAnnotation *startAnnotation = [[UICRouteAnnotation alloc] initWithCoordinate:[[routePoints objectAtIndex:0] coordinate]
																					title:startPoint
																		   annotationType:UICRouteAnnotationTypeStart] ;
	UICRouteAnnotation *endAnnotation = [[UICRouteAnnotation alloc] initWithCoordinate:[[routePoints lastObject] coordinate]
                                                                                  title:endPoint
                                                                         annotationType:UICRouteAnnotationTypeEnd];
	if ([wayPoints count] > 0) {
		NSInteger numberOfRoutes = [directions numberOfRoutes];
		for (NSInteger index = 0; index < numberOfRoutes; index++) {
			UICGRoute *route = [directions routeAtIndex:index];
			CLLocation *location = [route endLocation];
			UICRouteAnnotation *annotation = [[UICRouteAnnotation alloc] initWithCoordinate:[location coordinate]
																					   title:[[route endGeocode] objectForKey:@"address"]
																			  annotationType:UICRouteAnnotationTypeWayPoint];
			[_map addAnnotation:annotation];
		}
	}
    
	[_map addAnnotations:[NSArray arrayWithObjects:startAnnotation, endAnnotation, nil]];
}

- (void)directions:(UICGDirections *)directions didFailWithMessage:(NSString *)message {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Map Directions" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alertView show];
}


- (void)update {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	UICGDirectionsOptions *options = [[UICGDirectionsOptions alloc] init];
	options.travelMode = travelMode;
	if ([wayPoints count] > 0) {
		NSArray *routePoints = [NSArray arrayWithObject:startPoint];
		routePoints = [routePoints arrayByAddingObjectsFromArray:wayPoints];
		routePoints = [routePoints arrayByAddingObject:endPoint];
		[diretions loadFromWaypoints:routePoints options:options];
	} else {
		[diretions loadWithStartPoint:startPoint endPoint:endPoint options:options];
	}
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
//    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps?saddr=Current%20Location&daddr=%@,%@", _event.latitude, _event.longitude]]];    
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
        
        annotationView.enabled = YES;
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    
    if (routeOverlayView != nil) {
        
        routeOverlayView.hidden = YES;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    if (routeOverlayView != nil) {
        
        routeOverlayView.hidden = NO;
        [routeOverlayView setNeedsDisplay];   
    }
}

- (void)hideAllModal
{
    [_map setShowsUserLocation:NO];
    _map = nil;
    routeOverlayView = nil;
    startPoint = nil;
    endPoint = nil;
    diretions = nil;
    [self dismissModalViewControllerAnimated:YES];
}

@end
