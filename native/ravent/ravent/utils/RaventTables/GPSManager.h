//
//  GPSManager.h
//  ravent
//
//  Created by florian haftman on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString *const GPSDone;

@interface GPSManager : NSObject<CLLocationManagerDelegate> {
    
    CLLocationManager *_locationManager;
    NSDate *_locationLastUpdateTime;
    CLLocation *_bestEffortAtLocation;
}

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) NSError *error;

- (void)startGps;
- (void)stopGps:(NSError *)error;

+ (GPSManager *)instance;

@end
