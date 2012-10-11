//
//  MapSingleton.h
//  ravent
//
//  Created by flo on 10/9/12.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapSingleton : NSObject {
    
    MKMapView *_map;
}

@property (nonatomic, strong) MKMapView *map;

+ (MapSingleton *)instance;

@end
