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
#import "controllers_events_Details.h"
#import "STSegmentedControl.h"

#define METERS_PER_MILE 1609.344

@interface controllers_events_Details_Map : UIViewController<MKMapViewDelegate, MKAnnotation> {
    
    MKMapView *_map;
    STSegmentedControl *_segmentedControl;

    models_Event *_event;
    
    controllers_events_Details *_parent;
    
    IBOutlet UIImageView *_googleBranding;
}

- (id)initWithEvent:(models_Event *)event andParent:(controllers_events_Details *)p;
- (void)mydealloc;
- (IBAction)onDirections_Tap:(id)sender;

@end
