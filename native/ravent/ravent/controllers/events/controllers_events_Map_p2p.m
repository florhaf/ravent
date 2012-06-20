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
#import <RestKit/RKErrorMessage.h>

@implementation controllers_events_Map_p2p

static controllers_events_Map_p2p *_ctrl;

@synthesize coordinate;
@synthesize peekLeftAmount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(models_User *)user
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
//        _imageLoading = [[NSMutableDictionary alloc] init];
        _user = user;
    }
    return self;
}

- (void)updateLoadingMessageWith:(NSString *)text
{
    
    if (_hud != nil) {
        
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        [MBProgressHUD showHUDAddedTo:self.view animated:NO withText:text];
    }
}

- (void)loading
{
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _isMapSet = NO;
}

- (void)loadData:(NSArray *)objects
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    _hud = nil;
    
    for (id<MKAnnotation> annotation in _map.annotations) {
        
        [_map removeAnnotation:annotation];
    }
    
    if ([objects count] > 0) {
        
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

- (IBAction)onOptionsTap:(id)sender
{
    [_map raceTo:CGPointMake(0, -_tableOptions.frame.size.height) withSnapBack:YES];
    [_tableOptions raceTo:CGPointMake(0, 460 -_tableOptions.frame.size.height) withSnapBack:YES];
    
    UIBarButtonItem *btn = (UIBarButtonItem *)sender;
    
    [btn setStyle:UIBarButtonItemStyleDone];
    [btn setAction:@selector(onDoneTap:)];
    
    _isOptionsShowing = YES;
    
    _prevRadiusValue = [models_User crtUser].searchRadius;
    _prevWindowValue = [models_User crtUser].searchWindow;
}

- (IBAction)onDoneTap:(id)sender
{
    [_map raceTo:CGPointMake(0, 0) withSnapBack:YES];
    [_tableOptions raceTo:CGPointMake(0, 460) withSnapBack:YES];
    
    UIBarButtonItem *btn = (UIBarButtonItem *)sender;
    
    [btn setStyle:UIBarButtonSystemItemSearch];
    [btn setAction:@selector(onOptionsTap:)];
    
    _isOptionsShowing = NO;
    
    if (_prevRadiusValue != [models_User crtUser].searchRadius ||
        _prevWindowValue != [models_User crtUser].searchWindow) {
        
        [self performSelector:@selector(resetTopViewAfterDelayCallback) withObject:nil afterDelay:0.9 inModes:[[NSArray alloc] initWithObjects:NSRunLoopCommonModes, nil]];
        
        [[controllers_events_List_p2p instance] loadDataWithSpinner];
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
        
//    UIImageView *imgTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toolbar"]];
//    UIImageView *imgBottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toolbar"]];
//    imgTop.frame = CGRectMake(0, 0, 320, 44);
//    imgBottom.frame = CGRectMake(0, 0, 320, 44);
    
    //[_toolbarTop insertSubview:imgTop atIndex:1];
    //[_toolbarBottom insertSubview:imgBottom atIndex:1];
    
    
//    UIImage *soi = [UIImage imageNamed:@"searchoptions"];
//    UIButton *sob = [UIButton buttonWithType:UIButtonTypeCustom];
//    [sob addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
//    [sob setImage:soi forState:UIControlStateNormal];
//    [sob setFrame:CGRectMake(-20, 0, 270, 44)];
//    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:sob];
//    NSArray *items = [[NSArray alloc] initWithObjects:button, nil];
//    [_toolbarBottom setItems:items];
    
    
    self.peekLeftAmount = 40.0f;
    [self.slidingViewController setAnchorLeftPeekAmount:self.peekLeftAmount];
    self.slidingViewController.underRightWidthLayout = ECVariableRevealWidth;
}

- (void)stopGps
{
    _map.showsUserLocation = NO;
}

- (void)startGps
{
    _map.showsUserLocation = YES;
    
    [MBProgressHUD hideHUDForView:self.view animated:NO];
}

- (IBAction)buttonTap:(id)sender
{
    //_map.showsUserLocation = !_map.showsUserLocation;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.08;
    span.longitudeDelta = 0.08;
    
    CLLocationCoordinate2D location;
    
    location.latitude = userLocation.coordinate.latitude;
    location.longitude = userLocation.coordinate.longitude;
    
    region.span = span;
    region.center = location;
    
    [mapView setRegion:region animated:YES];
}

//- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
//{
//    [self setMapLocation:NO];
//}

//- (void)setMapLocation:(BOOL)force
//{
//    CLLocationCoordinate2D zoomLocation;
//    
//    zoomLocation.latitude  = [[models_User crtUser].latitude doubleValue];
//    zoomLocation.longitude = [[models_User crtUser].longitude doubleValue];
//    
//    if (!_isMapSet || force) {
//        
//        _isMapSet = YES;
//        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 2 * METERS_PER_MILE, 2 * METERS_PER_MILE);
//        MKCoordinateRegion adjustedRegion = [_map regionThatFits:viewRegion];                
//        [_map setRegion:adjustedRegion animated:YES];
//        
//        //_map.showsUserLocation = YES;
//    }
//}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    _isMapSet = NO;
//    [self setMapLocation:YES];
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
        
        
//        NSURL *url = [NSURL URLWithString:e.picture];
//        
//        _image = [[JBAsyncImageView alloc] init];
//        [_image setDelegate:self];
//        [_image setImageURL:url];
//        
//        NSMutableArray *annotAndImage = [[NSMutableArray alloc] initWithCapacity:2];
//        [annotAndImage addObject:annotationView];
//        [annotAndImage addObject:_image];
//        
//        [_imageLoading setObject:annotAndImage forKey:url];
        
//        annotationView.image = [UIImage imageNamed:@"AnnotationEvent"];
        
        annotationView.image = [UIImage imageNamed:@"diamond"];
        [annotationView setFrame:CGRectMake(0, 0, 24, 18)];
        
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

    NSArray *array = [[NSArray alloc] initWithObjects:event, nil];
    [[ActionDispatcher instance] execute:@"controller_events_List_p2p_loadDetails" with:array];
    
//    controllers_events_Details *details = [[controllers_events_Details alloc] initWithEvent:[event copy]];
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: self action:nil];
//    UIViewController *rootController = self;
//    
//    while (![rootController.parentViewController isKindOfClass:[UINavigationController class]]) {
//        
//        rootController = rootController.parentViewController;
//    }
//    
//    [rootController.navigationItem setBackBarButtonItem: backButton];
//    [self.navigationController pushViewController:details animated:YES];
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


#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Search";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        
        for (int i = 0; i < [cell.contentView.subviews count]; i++) {
            
            [[cell.contentView.subviews objectAtIndex:i] removeFromSuperview];
        }
    }
    
    if (indexPath.row == 0) {
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
        [v setBackgroundColor:[UIColor clearColor]];
        
        UILabel *l1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 44)];
        [l1 setText:@"Radius"];
        [l1 setBackgroundColor:[UIColor clearColor]];
        [l1 setTextColor:[UIColor darkGrayColor]];
        
        _labelRadiusValue = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, 90, 44)];
        [_labelRadiusValue setTextColor:[UIColor darkGrayColor]];
        [_labelRadiusValue setText:[NSString stringWithFormat:@"%d mi.", [models_User crtUser].searchRadius]];
        [_labelRadiusValue setBackgroundColor:[UIColor clearColor]];
        
        UIStepper *s = [[UIStepper alloc] initWithFrame:CGRectMake(160, 10, 50, 44)];
        s.value = [models_User crtUser].searchRadius;
        s.minimumValue = 5;
        s.maximumValue = 50;
        s.stepValue = 5;
        s.continuous = NO;
        
        [s addTarget:self action:@selector(stepperRadiusPressed:) forControlEvents:UIControlEventValueChanged];
        
        [v addSubview:l1];
        [v addSubview:_labelRadiusValue];
        [v addSubview:s];
        
        [cell.contentView addSubview:v];
        
    } else {
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
        [v setBackgroundColor:[UIColor clearColor]];
        
        UILabel *l1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 44)];
        [l1 setText:@"Window"];
        [l1 setTextColor:[UIColor darkGrayColor]];
        
        _labelWindowValue = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, 90, 44)];
        [_labelWindowValue setTextColor:[UIColor darkGrayColor]];
        [_labelWindowValue setText:[NSString stringWithFormat:@"%d h.", [models_User crtUser].searchWindow]];
        
        UIStepper *s = [[UIStepper alloc] initWithFrame:CGRectMake(160, 10, 50, 44)];
        s.value = [models_User crtUser].searchWindow;
        s.minimumValue = 12;
        s.maximumValue = 72;
        s.stepValue = 12;
        s.continuous = NO;
        
        [s addTarget:self action:@selector(stepperWindowPressed:) forControlEvents:UIControlEventValueChanged];
        
        [v addSubview:l1];
        [v addSubview:_labelWindowValue];
        [v addSubview:s];
        
        [cell.contentView addSubview:v];
    }
    
    return cell;
}

- (void)stepperRadiusPressed:(UIStepper *)sender
{
    [models_User crtUser].searchRadius = (int)sender.value;
    _labelRadiusValue.text = [NSString stringWithFormat:@"%d mi.",  (int)sender.value];
}

- (void)stepperWindowPressed:(UIStepper *)sender
{
    [models_User crtUser].searchWindow = (int)sender.value;
    _labelWindowValue.text = [NSString stringWithFormat:@"%d h.", (int)sender.value];    
}

+ (controllers_events_Map_p2p *)instance
{
    if (_ctrl == nil) {
        
        _ctrl = [[controllers_events_Map_p2p alloc] initWithNibName:@"views_events_Map" bundle:nil user:[[models_User crtUser] copy]];        
    }
    
    return _ctrl;
}

+ (void)release
{
    _ctrl = nil;
}

@end
