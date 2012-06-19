//
//  GPSManager.m
//  ravent
//
//  Created by florian haftman on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GPSManager.h"

NSString *const GPSDone = @"GPSDone";

static GPSManager *_gps;

@implementation GPSManager

@synthesize isLoading = _isLoading;
@synthesize currentLocation = _currentLocation;
@synthesize error = _error;

- (void)startGps
{
    _isLoading = YES;
    
    if (_locationManager == nil) {
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = 100;
        
    }
    
    _bestEffortAtLocation = nil;
    
    [_locationManager startUpdatingLocation];
    
    //NSError *error = [[NSError alloc] initWithDomain:@"GPS Timed Out" code:0 userInfo:nil];
    [self performSelector:@selector(stopGps:) withObject:nil afterDelay:15];
}

- (void)stopGps:(NSError *)error
{
    _isLoading = NO;
    
    [_locationManager stopUpdatingLocation];
    
    _currentLocation = _bestEffortAtLocation;
    
    _error = error;
    [[NSNotificationCenter defaultCenter] postNotificationName:GPSDone object:self];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{	
    _error = error;
    _isLoading = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GPSDone object:self];
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeStyle:NSDateFormatterMediumStyle];

    
    if (newLocation.horizontalAccuracy < 0) 
        return;

    if (_bestEffortAtLocation == nil || _bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {

        _bestEffortAtLocation = newLocation;
        _locationLastUpdateTime = [NSDate date];

        if (newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy) {
            _isLoading = NO;
            _currentLocation = newLocation;
            [_locationManager stopUpdatingLocation];

            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopGps:) object:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GPSDone object:self];
        }
    }
}

+ (GPSManager *)instance
{
    if (_gps == nil) {
        
        _gps = [[GPSManager alloc] init];
    }
    
    return _gps;
}

@end
