//
//  MapSingleton.m
//  ravent
//
//  Created by flo on 10/9/12.
//
//

#import "MapSingleton.h"

@implementation MapSingleton

@synthesize map = _map;

static MapSingleton *_mapSingleton;

- (id)init
{
    self = [super init];
    
    if (self) {
        
        _map = [[MKMapView alloc] init];
    }
    
    return self;
}

+ (MapSingleton *)instance
{
    if (_mapSingleton == nil) {
        
        _mapSingleton = [[MapSingleton alloc] init];
    }
    
    return _mapSingleton;
}

@end
