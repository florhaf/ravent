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

@interface controllers_events_Map_p2p : UIViewController<MKMapViewDelegate, MKAnnotation, JBAsyncImageViewDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    IBOutlet MKMapView *_map;
    IBOutlet UIToolbar *_toolbarTop;
    IBOutlet UIToolbar *_toolbarBottom;
    IBOutlet UITableView *_tableOptions;
    
    UILabel *_labelRadiusValue;
    UILabel *_labelWindowValue;
    
    NSMutableDictionary *_imageLoading;
    JBAsyncImageView *_image;
    
    models_User *_user;
    
    MBProgressHUD *_hud;
    
    BOOL _isMapSet;
    BOOL _isOptionsShowing;
    
    
    int _prevRadiusValue;
    int _prevWindowValue;
}

@property (nonatomic, assign) CGFloat peekLeftAmount;

- (IBAction)buttonTap:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(models_User *)user;
- (void)loading;
- (void)loadData:(NSArray *)objects;
//- (void)setMapLocation:(BOOL)force;
- (void)updateLoadingMessageWith:(NSString *)text;
- (void) stopGps;
- (void) startGps;

- (IBAction)onOptionsTap:(id)sender;
- (IBAction)onDoneTap:(id)sender;

+ (controllers_events_Map_p2p *)instance;
+ (void)release;

@end
