//
//  controllers_events_Details_Map.h
//  ravent
//
//  Created by florian haftman on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "models_Event.h"
#import <MapKit/MapKit.h>
#import "STSegmentedControl.h"

#define METERS_PER_MILE 1609.344

@interface controllers_events_Details_Map : UIViewController<MKMapViewDelegate, MKAnnotation> {
    
    IBOutlet MKMapView *_map;
    STSegmentedControl *_segmentedControl;
	NSString *startPoint;
	NSString *endPoint;
	NSArray *wayPoints;

    models_Event *_event;
}

@property (nonatomic, retain) NSString *startPoint;
@property (nonatomic, retain) NSString *endPoint;
@property (nonatomic, retain) NSArray *wayPoints;


- (id)initWithEvent:(models_Event *)event;

- (IBAction)onDirections_Tap:(id)sender;

@end
