//
//  controllers_events_Options_p2p.m
//  ravent
//
//  Created by florian haftman on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_events_Options_p2p.h"
#import "models_User.h"

@implementation controllers_events_Options_p2p

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"Ravent";
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidUnload];
//   
//    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hideOptionsModal)];        
//    UIBarButtonItem *locateButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(hideOptionsModal)];        
//    
//    self.navigationItem.rightBarButtonItem = doneButton;
//    self.navigationItem.leftBarButtonItem = locateButton;
//    
//    ((UIScrollView *)[self.view.subviews objectAtIndex:0]).contentSize = CGSizeMake(320, 565);
//    
//    CLLocationCoordinate2D zoomLocation;
//    zoomLocation.latitude = [[models_User crtUser].latitude floatValue];
//    zoomLocation.longitude= [[models_User crtUser].longitude floatValue];
//    
//    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 5*METERS_PER_MILE, 5*METERS_PER_MILE);
//    MKCoordinateRegion adjustedRegion = [_map regionThatFits:viewRegion];                
//    
//    [_map setRegion:adjustedRegion animated:YES];
//    
//    _map.showsUserLocation = YES;
}

- (void)hideOptionsModal
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
