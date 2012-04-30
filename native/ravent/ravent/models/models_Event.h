//
//  models_Event.h
//  ravent
//
//  Created by florian haftman on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <MapKit/MapKit.h>

@interface models_Event : NSObject<RKObjectLoaderDelegate, RKRequestDelegate, MKAnnotation> {
    
    id __unsafe_unretained _delegate;
    SEL _callback;
    
    // callback for raw response
    SEL _callbackResponseSuccess;
    SEL _callbackResponseFailure;
    id _sender;
    
    RKObjectManager *_manager;    
    
    NSString *_eid;
    NSString *_name;
    NSString *_location;
    NSString *_picture;
    NSString *_score;
    NSString *_timeStart;
    NSString *_timeEnd;
    NSString *_distance;
    NSString *_group;
    NSString *_description;
    NSString *_dateStart;
    NSString *_dateEnd;
    NSString *_latitude;
    NSString *_longitude;
    NSString *_groupTitle;
    
    CLLocationCoordinate2D _coordinate;
}

@property (unsafe_unretained) id delegate;
@property (nonatomic, assign) SEL callback;

@property (nonatomic, assign) SEL callbackResponseSuccess;
@property (nonatomic, assign) SEL callbackResponseFailure;

@property (nonatomic, retain) NSString *eid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *picture;
@property (nonatomic, retain) NSString *score;
@property (nonatomic, retain) NSString *timeStart;
@property (nonatomic, retain) NSString *timeEnd;
@property (nonatomic, retain) NSString *distance;
@property (nonatomic, retain) NSString *group;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *dateStart;
@property (nonatomic, retain) NSString *dateEnd;
@property (nonatomic, retain) NSString *latitude;
@property (nonatomic, retain) NSString *longitude;
@property (nonatomic, retain) NSString *groupTitle;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (id)initWithDelegate:(NSObject *)del andSelector:(SEL)sel;
- (void)loadEventsWithParams:(NSMutableDictionary *)params;
- (void)loadDescription;
- (void)vote:(NSMutableDictionary *)params success:(SEL)success failure:(SEL)failure sender:(id)sender;
- (void)cancelAllRequests;

+ (NSMutableDictionary *)getGroupedData:(NSArray *)data;

@end
