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

@implementation controllers_events_Map_p2p

@synthesize coordinate;
@synthesize peekLeftAmount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(models_User *)user
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        Action *loadingAction = [[Action alloc] initWithDelegate:self andSelector:@selector(loading)];
        Action *loadDataAction = [[Action alloc] initWithDelegate:self andSelector:@selector(loadData:)];
        
        [[ActionDispatcher instance] add:loadingAction named:@"controller_events_List_p2p_Loading"];
        [[ActionDispatcher instance] add:loadDataAction named:@"controller_events_List_p2p_LoadData"];
        
        _imageLoading = [[NSMutableDictionary alloc] init];
        _user = user;
    }
    return self;
}

- (void)loading
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)loadData:(NSArray *)objects
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self setMapLocation:YES];
    
    if ([objects count] > 0) {
        
        id object = [objects objectAtIndex:0];
        
        if ([object isKindOfClass:[NSError class]]) {
            
//            NSError *error = (NSError *)object;
            
//            [YRDropdownView showDropdownInView:self.view
//                                         title:@"Error" 
//                                        detail:[error localizedDescription]
//                                         image:[UIImage imageNamed:@"dropdown-alert"]
//                                      animated:YES];
        } else {
            
            for (id<MKAnnotation> annotation in _map.annotations) {
                
                [_map removeAnnotation:annotation];
            }
            
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
        
//        [YRDropdownView showDropdownInView:self.view
//                                     title:@"Warning" 
//                                    detail:@"No result"
//                                     image:[UIImage imageNamed:@"dropdown-alert"]
//                                  animated:YES];
    }   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self setMapLocation:YES];
    
    self.peekLeftAmount = 40.0f;
    [self.slidingViewController setAnchorLeftPeekAmount:self.peekLeftAmount];
    self.slidingViewController.underRightWidthLayout = ECVariableRevealWidth;
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    //[self setMapLocation:NO];
}

- (void)setMapLocation:(BOOL)force
{
    CLLocationCoordinate2D zoomLocation;
    
    zoomLocation.latitude  = [[models_User crtUser].latitude doubleValue];
    zoomLocation.longitude = [[models_User crtUser].longitude doubleValue];
    
    if (!_isMapSet || force) {
        
        _isMapSet = YES;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 2 * METERS_PER_MILE, 2 * METERS_PER_MILE);
        MKCoordinateRegion adjustedRegion = [_map regionThatFits:viewRegion];                
        [_map setRegion:adjustedRegion animated:YES];
        
        _map.showsUserLocation = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setMapLocation:YES];
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
        
        NSURL *url = [NSURL URLWithString:e.picture];
        
        _image = [[JBAsyncImageView alloc] init];
        [_image setDelegate:self];
        [_image setImageURL:url];
        
        NSMutableArray *annotAndImage = [[NSMutableArray alloc] initWithCapacity:2];
        [annotAndImage addObject:annotationView];
        [annotAndImage addObject:_image];
        
        [_imageLoading setObject:annotAndImage forKey:url];
        
        annotationView.image = [UIImage imageNamed:@"AnnotationEvent"];
        annotationView.annotation = annotation;
        [annotationView setCenterOffset:CGPointMake(0, - annotationView.image.size.height / 2)];
        
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.rightCalloutAccessoryView = infoButton;
        
        return annotationView;
    }
    
    return nil;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    models_Event *event = (models_Event *)view.annotation;

    controllers_events_Details *details = [[controllers_events_Details alloc] initWithEvent:[event copy]];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: self action:nil];
    UIViewController *rootController = self;
    
    while (![rootController.parentViewController isKindOfClass:[UINavigationController class]]) {
        
        rootController = rootController.parentViewController;
    }
    
    [rootController.navigationItem setBackBarButtonItem: backButton];
    [self.navigationController pushViewController:details animated:YES];
}

-(void)imageView:(JBAsyncImageView *)sender loadedImage:(UIImage *)imageLoaded fromURL:(NSURL *)url
{
    MKAnnotationView *annotation = [((NSMutableArray *)[_imageLoading objectForKey:url]) objectAtIndex:0];
    
    UIGraphicsBeginImageContext(annotation.image.size);
    [annotation.image drawInRect:CGRectMake(0, 0, annotation.image.size.width, annotation.image.size.height)];
    [imageLoaded drawInRect:CGRectMake(8, 8, 56, 56)];
    annotation.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [_imageLoading removeObjectForKey:url];
}

@end
