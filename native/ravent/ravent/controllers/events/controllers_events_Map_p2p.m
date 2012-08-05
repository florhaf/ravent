//
//  controllers_events_Map_p2p.m
//  ravent
//
//  Created by florian haftman on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_events_Map_p2p.h"
#import "controllers_events_Details.h"
#import "models_Event.h"
#import "MBProgressHUD.h"
#import "YRDropdownView.h"
#import "ActionDispatcher.h"
#import "UIView+Animation.h"
#import "controllers_events_List_p2p.h"
#import "controllers_App.h"
#import "controllers_events_Events.h"
#import <RestKit/RKErrorMessage.h>

@implementation controllers_events_Map_p2p

static controllers_events_Map_p2p *_ctrl;

static int _retryCounter;

@synthesize coordinate;
@synthesize peekLeftAmount;
@synthesize boundingMapRect;

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(models_User *)user
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _user = user;
        
    }
    return self;
}

- (void)loading
{
    _isMapSet = NO;
}

- (void)loadData:(NSArray *)objects
{
    
    for (id<MKAnnotation> annotation in _map.annotations) {
        
        [_map removeAnnotation:annotation];
    }
    
    if (objects != nil && [objects count] > 0) {
        
        id object = [objects objectAtIndex:0];
        
        if ([object isKindOfClass:[NSError class]] ||
            [object isKindOfClass:[RKErrorMessage class]]) {
            
            // error shown on the list itself
            
        } else {
            
            
            
            for (int i = 0; i < [objects count]; i++) {
                
                models_Event *e = [objects objectAtIndex:i];
                CLLocationCoordinate2D coord;
                coord.latitude = [e.latitude doubleValue];
                coord.longitude = [e.longitude doubleValue];
                e.coordinate = coord;
                [_map addAnnotation:e];
            }
        }
    } else {
        
        // no result shown on the list itself
    }   
}

- (void)resetTopViewAfterDelayCallback
{
    [self.slidingViewController resetTopView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startGps) name:ECSlidingViewUnderRightWillAppear object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopGps) name:ECSlidingViewTopDidReset object:nil];
    
    UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRec setDelegate:self];
    [_map addGestureRecognizer:panRec];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
    
    if (_isSettingLocation) {
        
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
            
            _overlayCircle = [MKCircle circleWithCenterCoordinate:_map.region.center radius:1000 * 1.61 * 6];
            [_map addOverlay:_overlayCircle];
            _overlay.hidden = YES;
            _isDirty = YES;
        }
        
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            
            [_map removeOverlay:_overlayCircle];
            _overlayCircle = nil;
            _overlay.hidden = NO;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.peekLeftAmount = 40.0f;
    [self.slidingViewController setAnchorLeftPeekAmount:self.peekLeftAmount];
    self.slidingViewController.underRightWidthLayout = ECVariableRevealWidth;
    
    [self trackPageView:@"events_p2p_map" forEvent:nil];
}

- (void)stopGps
{
    _map.showsUserLocation = NO;
    _isMapSet = NO;
    
    [_map removeOverlay:_overlayCircle];
    _isSettingLocation = NO;
    [_buttonChangeLocation setTitle:@"Change Location" forState:UIControlStateNormal];
}

- (void)startGps
{
    _map.showsUserLocation = YES;
}

- (IBAction)buttonTap:(id)sender
{
    MKCoordinateSpan span;
    
    if (_isSettingLocation) {
        
        [_buttonChangeLocation setTitle:@"Change Location" forState:UIControlStateNormal];
        _isSettingLocation = NO;
        
        span.latitudeDelta = 0.08;
        span.longitudeDelta = 0.08;
        
        _overlayView.fillColor = [[UIColor grayColor] colorWithAlphaComponent:0];
        _map.zoomEnabled = YES;
        
        [controllers_events_List_p2p instance].searchCenter = _map.region.center;
        
        if (_isDirty) {
            
            _isDirty = NO;
            
            if (!((controllers_events_Events *)[[controllers_events_Events instance].childViewControllers objectAtIndex:0 ]).isUp) {
                
                [self performSelector:@selector(resetTopViewAfterDelayCallback) withObject:nil afterDelay:0.5];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"locationChangedReloadDelayed" object:self];
            } else {
             
                [self performSelector:@selector(resetTopViewAfterDelayCallback) withObject:nil afterDelay:0.5];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"locationChanged" object:self];
            }
        } 
    } else {
        
        [_buttonChangeLocation setTitle:@"Done" forState:UIControlStateNormal];
        _isSettingLocation = YES;
        
        span.latitudeDelta = 0.2;
        span.longitudeDelta = 0.2;
        
        _overlayView.fillColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
        
        _map.zoomEnabled = NO;
    }
    
    CLLocationCoordinate2D coord;
    coord.latitude = _map.region.center.latitude;
    coord.longitude = _map.region.center.longitude;
    
    MKCoordinateRegion region;
    region.span = span;
    region.center = coord;
    
    [_map setRegion:region animated:YES];
}

- (void)buttonTapWithDelay:(id)sender
{
    _executeButtonTapWithDelay = YES;
    
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{    
    if (_isMapSet) {
        
        return;
    }
    
    
    
    _isMapSet = YES;
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.08;
    span.longitudeDelta = 0.08;
    
    CLLocationCoordinate2D location;
    
    if ([controllers_events_List_p2p instance].searchCenter.latitude == 0) {
        
        location.latitude = userLocation.coordinate.latitude;
        location.longitude = userLocation.coordinate.longitude;
    } else {
        
        location = [controllers_events_List_p2p instance].searchCenter;
    }
    region.span = span;
    region.center = location;
    
    _overlayCircle = [MKCircle circleWithCenterCoordinate:location radius:1000 * 1.61 * 6];
    [_map addOverlay:_overlayCircle];
    
    @try {
        
        if (_executeButtonTapWithDelay) {
            
            _executeButtonTapWithDelay = NO;
            [mapView setRegion:region animated:NO];
            [self performSelector:@selector(buttonTap:) withObject:nil afterDelay:0];
        } else {
            
            [mapView setRegion:region animated:YES];   
        }
    }
    @catch (NSException *exception) {
        
        // retry a few times...
        if (_retryCounter < 4) {
            
            _retryCounter++;
            
            [self mapView:mapView didUpdateUserLocation:userLocation];
        } else {
            
            _retryCounter = 0;
            
            [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                         title:@"Map Error" 
                                        detail:exception.reason
                                         image:[UIImage imageNamed:@"dropdown-alert"]
                                      animated:YES];
        }
    }
    @finally {
        // nothing
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
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
        annotationView.canShowCallout = YES;
 
        
        annotationView.image = [UIImage imageNamed:@"diamondSmall"];
        [annotationView setFrame:CGRectMake(0, 0, 24, 20)];
        
        annotationView.annotation = annotation;
        [annotationView setCenterOffset:CGPointMake(annotationView.image.size.width / 2, annotationView.image.size.height / 2)];
        
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.rightCalloutAccessoryView = infoButton;
        
        return annotationView;
    }
    
    return nil;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    models_Event *event = (models_Event *)view.annotation;

    NSArray *array = [[NSArray alloc] initWithObjects:event, nil];
    [[ActionDispatcher instance] execute:@"controller_events_List_p2p_loadDetails" with:array];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    _overlayView = [[MKCircleView alloc] initWithOverlay:overlay];
    _overlayView.strokeColor = [UIColor darkGrayColor];
    _overlayView.fillColor = [[UIColor grayColor] colorWithAlphaComponent:(_isSettingLocation) ? 0.5 : 0];
    return _overlayView;
}

+ (controllers_events_Map_p2p *)instance
{
    if (_ctrl == nil) {
        
        _ctrl = [[controllers_events_Map_p2p alloc] initWithNibName:@"views_events_Map" bundle:nil user:[[models_User crtUser] copy]];        
        
        _retryCounter = 0;
    }
    
    return _ctrl;
}

+ (void)deleteInstance
{
    _ctrl = nil;
}

- (void)dealloc {
    _map = nil;
    _toolbarTop = nil;
    _toolbarBottom = nil;
    _tableOptions = nil;
    _buttonChangeLocation = nil;
    _overlayView = nil;
    _overlayCircle = nil;
    _overlay = nil;
    
    _user = nil;
}

@end
