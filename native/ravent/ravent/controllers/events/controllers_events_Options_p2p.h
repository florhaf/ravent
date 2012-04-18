//
//  controllers_events_Options_p2p.h
//  ravent
//
//  Created by florian haftman on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#define METERS_PER_MILE 1609.344

@interface controllers_events_Options_p2p : UIViewController {
    
    IBOutlet MKMapView *_map;
}

- (void)hideOptionsModal;

@end
