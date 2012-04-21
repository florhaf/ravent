//
//  controllers_events_Map_p2p.h
//  ravent
//
//  Created by florian haftman on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "JBAsyncImageView.h"
#import "models_User.h"

#import "ECSlidingViewController.h"

#define METERS_PER_MILE 1609.344

@interface controllers_events_Map_p2p : UIViewController<MKMapViewDelegate, MKAnnotation, JBAsyncImageViewDelegate> {
    
    IBOutlet MKMapView *_map;
    
    NSMutableDictionary *_imageLoading;
    JBAsyncImageView *_image;
    
    models_User *_user;
    
    BOOL _isMapSet;
}

@property (nonatomic, unsafe_unretained) CGFloat peekLeftAmount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(models_User *)user;
- (void)loading;
- (void)loadData:(NSArray *)objects;
- (void)setMapLocation:(BOOL)force;

+ (controllers_events_Map_p2p *)instance;

@end
