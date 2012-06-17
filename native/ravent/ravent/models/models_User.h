//
//  models_User.h
//  ravent
//
//  Created by florian haftman on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
//#import <CoreLocation/CoreLocation.h>

@interface models_User : NSObject<RKObjectLoaderDelegate, RKRequestDelegate/*, CLLocationManagerDelegate*/> {
    
    id __unsafe_unretained _delegate;
    // callback for object loading
    SEL _callback;
    // callback for raw response
    SEL _callbackResponseSuccess;
    SEL _callbackResponseFailure;
    id _sender;
    
//    CLLocationManager *_locationManager;
    id __unsafe_unretained _locationDelegate;
    SEL _locationSuccess;
    SEL _locationFailure;
//    NSDate *_locationLastUpdateTime;
//    CLLocation *_bestEffortAtLocation;
    
    BOOL _isRequesting;
    BOOL _isLoadingAllFriends;
    
    RKObjectManager *_manager;
    RKClient *_client;
    
    NSString *_uid;
    NSString *_fistName;
    NSString *_lastName;
    NSString *_picture;
    NSString *_group;
    NSString *_isFollowed;
    NSString *_isInvited;
    NSString *_rsvpStatus;
    NSString *_latitude;
    NSString *_longitude;
    NSString *_timeZone;
    NSString *_accessToken;
    
    NSString *_nbOfEvents;
    NSString *_nbOfFollowers;
    NSString *_nbOfFollowing;
}

@property (unsafe_unretained) id delegate;
@property (nonatomic, assign) SEL callback;
@property (nonatomic, assign) SEL callbackResponseSuccess;
@property (nonatomic, assign) SEL callbackResponseFailure;

//@property (nonatomic, retain) CLLocationManager *locationManager;
@property (unsafe_unretained) id locationDelegate;
@property (nonatomic, assign) SEL locationSuccess;
@property (nonatomic, assign) SEL locationFailure;

@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *picture;
@property (nonatomic, retain) NSString *group;
@property (nonatomic, retain) NSString *isFollowed;
@property (nonatomic, retain) NSString *isInvited;
@property (nonatomic, retain) NSString *rsvpStatus;
@property (nonatomic, retain) NSString *latitude;
@property (nonatomic, retain) NSString *longitude;
@property (nonatomic, retain) NSString *timeZone;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSString *nbOfEvents;
@property (nonatomic, retain) NSString *nbOfFollowers;
@property (nonatomic, retain) NSString *nbOfFollowing;

- (id)initWithDelegate:(NSObject *)del andSelector:(SEL)sel;
- (void)loadUser;
- (void)loadFollowingsWithParams:(NSMutableDictionary *)params;
- (void)loadAllWithParams:(NSMutableDictionary *)params force:(BOOL)force;
- (void)loadInvitedWithParams:(NSMutableDictionary *)params;
- (void)loadShareWithParams:(NSMutableDictionary *)params force:(BOOL)force;
- (void)cancelAllRequests;

- (void)getLocation;
- (void)dispatchLocation:(NSError *)error;

- (void)follow:(NSMutableDictionary *)params success:(SEL)success failure:(SEL)failure sender:(id)sender;
- (void)unfollow:(NSMutableDictionary *)params success:(SEL)success failure:(SEL)failure sender:(id)sender;

+ (NSMutableDictionary *)getGroupedData:(NSArray *)data;
+ (models_User *) crtUser;
+ (models_User *)setCrtUser:(models_User *)u;

@end
