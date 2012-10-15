//
//  controllers_events_Map_p2p.h
//  ravent
//
//  Created by florian haftman on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MBProgressHUD.h"
#import "JBAsyncImageView.h"
#import "models_User.h"

#import "ECSlidingViewController.h"

#define METERS_PER_MILE 1609.344

@interface controllers_events_Map_p2p : UIViewController<MKMapViewDelegate, MKAnnotation, MKOverlay, UIGestureRecognizerDelegate> {
    
    IBOutlet MKMapView *_map;
    IBOutlet UIToolbar *_toolbarTop;
    IBOutlet UIToolbar *_toolbarBottom;
    IBOutlet UITableView *_tableOptions;
    IBOutlet UIButton *_buttonChangeLocation;
    IBOutlet UIImageView *_overlay;
    IBOutlet UIImageView *_googleBranding;
    
    models_User *_user;
    MKCircleView *_overlayView;
    MKCircle *_overlayCircle;
    
    BOOL _isMapSet;
    BOOL _isSettingLocation;
    BOOL _isDirty;
    
    BOOL _executeButtonTapWithDelay;
}

@property (nonatomic, assign) CGFloat peekLeftAmount;
@property (nonatomic, retain) UIButton *buttonChangeLocation;

- (IBAction)buttonTap:(id)sender;
- (void)buttonTapWithDelay:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(models_User *)user;
- (void)loading;
- (void)loadData:(NSArray *)objects;
- (void) stopGps;
- (void) startGps;

+ (controllers_events_Map_p2p *)instance;
+ (void)deleteInstance;

@end
