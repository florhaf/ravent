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

@interface controllers_events_Map_p2p : UIViewController<MKMapViewDelegate, MKAnnotation, JBAsyncImageViewDelegate> {
    
    IBOutlet MKMapView *_map;
    IBOutlet UIToolbar *_toolbarTop;
    IBOutlet UIToolbar *_toolbarBottom;
    
    NSMutableDictionary *_imageLoading;
    JBAsyncImageView *_image;
    
    models_User *_user;
    
    MBProgressHUD *_hud;
    
    BOOL _isMapSet;
}

@property (nonatomic, unsafe_unretained) CGFloat peekLeftAmount;

- (IBAction)buttonTap:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(models_User *)user;
- (void)loading;
- (void)loadData:(NSArray *)objects;
//- (void)setMapLocation:(BOOL)force;
- (void)updateLoadingMessageWith:(NSString *)text;
- (void) stopGps;
- (void) startGps;

+ (controllers_events_Map_p2p *)instance;

@end
