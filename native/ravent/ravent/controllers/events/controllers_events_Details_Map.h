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

#define METERS_PER_MILE 1609.344

@interface controllers_events_Details_Map : UIViewController<MKMapViewDelegate, MKAnnotation> {
    
    IBOutlet MKMapView *_map;
    models_Event *_event;
}

- (id)initWithEvent:(models_Event *)event;

@end
