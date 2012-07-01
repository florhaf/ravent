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
#import "UICGDirections.h"
#import "UICRouteOverlayMapView.h"

#define METERS_PER_MILE 1609.344

@interface controllers_events_Details_Map : UIViewController<MKMapViewDelegate, MKAnnotation, UICGDirectionsDelegate> {
    
    IBOutlet MKMapView *_map;
    UICRouteOverlayMapView *routeOverlayView;
	UICGDirections *diretions;
	NSString *startPoint;
	NSString *endPoint;
	NSArray *wayPoints;
	UICGTravelModes travelMode;
    models_Event *_event;
}

@property (nonatomic, retain) NSString *startPoint;
@property (nonatomic, retain) NSString *endPoint;
@property (nonatomic, retain) NSArray *wayPoints;
@property (nonatomic) UICGTravelModes travelMode;

- (id)initWithEvent:(models_Event *)event;
- (void)update;

@end
