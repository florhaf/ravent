//
//  models_User.m
//  ravent
//
//  Created by florian haftman on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "models_User.h"

@implementation models_User

@synthesize delegate = _delegate;
@synthesize callback = _callback;
@synthesize callbackResponseSuccess = _callbackResponseSuccess;
@synthesize callbackResponseFailure = _callbackResponseFailure;

@synthesize locationManager = _locationManager;
@synthesize locationDelegate = _locationDelegate;
@synthesize locationSuccess = _locationSuccess;
@synthesize locationFailure = _locationFailure;

@synthesize uid = _uid;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize picture = _picture;
@synthesize group = _group;
@synthesize isFollowed = _isFollowed;
@synthesize isInvited = _isInvited;
@synthesize rsvpStatus = _rsvpStatus;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize timeZone = _timeZone;
@synthesize accessToken = _accessToken;
@synthesize nbOfEvents = _nbOfEvents;
@synthesize nbOfFollowers = _nbOfFollowers;
@synthesize nbOfFollowing = _nbOfFollowing;

//#define SERVICE_URL @"http://air.local:8888"
#define SERVICE_URL @"http://raventsvc.appspot.com"

#define LOCATION_UPDATE_INTERVAL 2

static NSArray* _allListSingleton = nil;
static models_User *_crtUser = nil;

- (id)init
{
    self = [super init];
    if (self != nil) {
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    return self;
}

- (id)initWithDelegate:(NSObject *)del andSelector:(SEL)sel
{
    self = [super init];
    if (self != nil) {
        
        _delegate = del;
        _callback = sel;
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    return self;
}

- (id)copy
{
    models_User *another = [[models_User alloc] init];
    
    another.uid = _uid;
    another.firstName = _firstName;
    another.lastName = _lastName;
    another.picture = _picture;
    another.group = _group;
    another.isFollowed = _isFollowed;
    another.isInvited = _isInvited;
    another.rsvpStatus = _rsvpStatus;
    another.latitude = _latitude;
    another.longitude = _longitude;
    another.timeZone = _timeZone;
    another.accessToken = _accessToken;
    another.nbOfEvents = _nbOfEvents;
    another.nbOfFollowers = _nbOfFollowers;
    another.nbOfFollowing = _nbOfFollowing;
    
    return another;
}

+ (models_User *)setCrtUser:(models_User *)u
{
    if (_crtUser == nil) {
        
        _crtUser = [[models_User alloc] init];
    }
    
    _crtUser.uid = u.uid;
    _crtUser.firstName = u.firstName;
    _crtUser.lastName = u.lastName;
    _crtUser.picture = u.picture;
    _crtUser.latitude = @"";
    _crtUser.longitude = @"";
    _crtUser.timeZone = [NSString stringWithFormat:@"%d", [[NSTimeZone localTimeZone] secondsFromGMT] / 60 ];
    _crtUser.accessToken = u.accessToken;

    return _crtUser;
}


+ (models_User *)crtUser
{
    return _crtUser;
}

- (void)getLocation
{
    //if (_locationLastUpdateTime == nil || [[NSDate date] timeIntervalSinceDate:_locationLastUpdateTime] < LOCATION_UPDATE_INTERVAL) {
     
        [_locationManager startUpdatingLocation];
    //}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [_locationManager stopMonitoringSignificantLocationChanges];
    [_locationManager stopUpdatingLocation];
    
    if (_locationLastUpdateTime != nil && [[NSDate date] timeIntervalSinceDate:_locationLastUpdateTime] < LOCATION_UPDATE_INTERVAL) {
        
        return;
    }
    
    _locationLastUpdateTime = [NSDate date];
    
    _crtUser.latitude = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
    _crtUser.longitude = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_locationDelegate performSelector:_locationSuccess];
#pragma clang diagnostic pop
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [_locationManager stopUpdatingLocation];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_locationDelegate performSelector:_locationFailure withObject:error];
#pragma clang diagnostic pop
}

- (void)loadUser
{
    RKLogConfigureByName("RestKit/*", RKLogLevelTrace);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:_uid forKey:@"userID"];
    
    if (_accessToken == nil || [_accessToken isEqualToString:@""]) {
     
        // load a friend
        [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
    } else {
        
        // load crt user
        [params setValue:_accessToken forKey:@"access_token"];
    }
    
    NSString *resourcePath = [@"users" appendQueryParams:params];
    
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[models_User class]];
    [objectMapping mapKeyPath:@"uid" toAttribute:@"uid"];
    [objectMapping mapKeyPath:@"first_name" toAttribute:@"firstName"];
    [objectMapping mapKeyPath:@"last_name" toAttribute:@"lastName"];
    [objectMapping mapKeyPath:@"picture" toAttribute:@"picture"];
    [objectMapping mapKeyPath:@"nb_of_events" toAttribute:@"nbOfEvents"];
    [objectMapping mapKeyPath:@"nb_of_followers" toAttribute:@"nbOfFollowers"];
    [objectMapping mapKeyPath:@"nb_of_following" toAttribute:@"nbOfFollowing"];
    
    if (_manager == nil) {
        
        _manager = [RKObjectManager objectManagerWithBaseURL:SERVICE_URL];
    }
    
    [_manager.mappingProvider setMapping:objectMapping forKeyPath:@"records"];
    [_manager loadObjectsAtResourcePath:resourcePath objectMapping:objectMapping delegate:self]; 
}

- (void)loadFollowingsWithParams:(NSMutableDictionary *)params
{
    NSString *resourcePath = [@"followings" appendQueryParams:params];
    
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[models_User class]];
    [objectMapping mapKeyPath:@"uid" toAttribute:@"uid"];
    [objectMapping mapKeyPath:@"first_name" toAttribute:@"firstName"];
    [objectMapping mapKeyPath:@"last_name" toAttribute:@"lastName"];
    [objectMapping mapKeyPath:@"picture" toAttribute:@"picture"];
    [objectMapping mapKeyPath:@"nb_of_events" toAttribute:@"nbOfEvents"];
    [objectMapping mapKeyPath:@"nb_of_followers" toAttribute:@"nbOfFollowers"];
    [objectMapping mapKeyPath:@"nb_of_following" toAttribute:@"nbOfFollowing"];
    
    if (_manager == nil) {
        
        _manager = [RKObjectManager objectManagerWithBaseURL:SERVICE_URL];
    }
    
    [_manager.mappingProvider setMapping:objectMapping forKeyPath:@"records"];
    [_manager loadObjectsAtResourcePath:resourcePath objectMapping:objectMapping delegate:self]; 
}

- (void)loadAllWithParams:(NSMutableDictionary *)params force:(BOOL)force
{
    if (!force && _allListSingleton) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_delegate performSelector:_callback withObject:_allListSingleton];
#pragma clang diagnostic pop
        return;
    }
    
    NSString *resourcePath = [@"friends" appendQueryParams:params];
    
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[models_User class]];
    [objectMapping mapKeyPath:@"uid" toAttribute:@"uid"];
    [objectMapping mapKeyPath:@"first_name" toAttribute:@"firstName"];
    [objectMapping mapKeyPath:@"last_name" toAttribute:@"lastName"];
    [objectMapping mapKeyPath:@"picture" toAttribute:@"picture"];
    
    if (_manager == nil) {
        
        _manager = [RKObjectManager objectManagerWithBaseURL:SERVICE_URL];
    }
    
    [_manager.mappingProvider setMapping:objectMapping forKeyPath:@"records"];
    [_manager loadObjectsAtResourcePath:resourcePath objectMapping:objectMapping delegate:self]; 
}

- (void)loadInvitedWithParams:(NSMutableDictionary *)params
{
    NSString *resourcePath = [@"attendings" appendQueryParams:params];
    
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[models_User class]];
    [objectMapping mapKeyPath:@"uid" toAttribute:@"uid"];
    [objectMapping mapKeyPath:@"first_name" toAttribute:@"firstName"];
    [objectMapping mapKeyPath:@"last_name" toAttribute:@"lastName"];
    [objectMapping mapKeyPath:@"picture" toAttribute:@"picture"];
    [objectMapping mapKeyPath:@"rsvp_status" toAttribute:@"rsvpStatus"];
    
    if (_manager == nil) {
        
        _manager = [RKObjectManager objectManagerWithBaseURL:SERVICE_URL];
    }
    
    [_manager.mappingProvider setMapping:objectMapping forKeyPath:@"records"];
    [_manager loadObjectsAtResourcePath:resourcePath objectMapping:objectMapping delegate:self]; 
}

- (void)loadShareWithParams:(NSMutableDictionary *)params force:(BOOL)force
{
    if (!force && _allListSingleton) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_delegate performSelector:_callback withObject:_allListSingleton];
#pragma clang diagnostic pop
        return;
    }
    
    NSString *resourcePath = [@"friends" appendQueryParams:params];
    
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[models_User class]];
    [objectMapping mapKeyPath:@"uid" toAttribute:@"uid"];
    [objectMapping mapKeyPath:@"first_name" toAttribute:@"firstName"];
    [objectMapping mapKeyPath:@"last_name" toAttribute:@"lastName"];
    [objectMapping mapKeyPath:@"picture" toAttribute:@"picture"];
    
    if (_manager == nil) {
        
        _manager = [RKObjectManager objectManagerWithBaseURL:SERVICE_URL];
    }
    
    [_manager.mappingProvider setMapping:objectMapping forKeyPath:@"records"];
    [_manager loadObjectsAtResourcePath:resourcePath objectMapping:objectMapping delegate:self]; 
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
        
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray* sortedObjects = [objects sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    if ([objectLoader.URL.path rangeOfString:@"friends"].location != NSNotFound) {
        
        _allListSingleton = [[NSArray alloc] initWithArray:sortedObjects];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_delegate performSelector:_callback withObject:sortedObjects];
#pragma clang diagnostic pop
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    NSArray *objects = [[NSArray alloc] initWithObjects:error, nil];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_delegate performSelector:_callback withObject:objects];
#pragma clang diagnostic pop
}

- (void)cancelAllRequests
{
    [[_manager requestQueue] cancelAllRequests];
    [[[RKClient sharedClient] requestQueue] cancelAllRequests];
}

- (void)follow:(NSMutableDictionary *)params success:(SEL)success failure:(SEL)failure sender:(id)sender
{
    _callbackResponseSuccess = success;
    _callbackResponseFailure = failure;
    _sender = sender;
    
    [[RKClient sharedClient] put:[@"followings" appendQueryParams:params] params:nil delegate:self];
}

- (void)unfollow:(NSMutableDictionary *)params success:(SEL)success failure:(SEL)failure sender:(id)sender
{
    _callbackResponseSuccess = success;
    _callbackResponseFailure = failure;
    _sender = sender;
    
    [[RKClient sharedClient] delete:[@"followings" appendQueryParams:params] delegate:self];
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    if ([request isGET]) {
        
        return;
    }
    
    if ([response isOK]) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_delegate performSelector:_callbackResponseSuccess withObject:[response bodyAsString]];
#pragma clang diagnostic pop   
    } else {
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:[NSString stringWithFormat:@"status code: %d", response.statusCode] forKey:@"statusCode"];
        [dic setValue:_sender forKey:@"sender"];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_delegate performSelector:_callbackResponseFailure withObject:dic];
#pragma clang diagnostic pop
    }
}

+ (NSMutableDictionary *)getGroupedData:(NSArray *)data
{  
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < [data count]; i++) {
        
        models_User *u = [data objectAtIndex:i];
        
        u.group = [u.lastName substringToIndex:1];
        u.group = [NSString stringWithFormat:@"%@%@",[[u.group substringToIndex:1] uppercaseString],[u.group substringFromIndex:1] ];
        
        int j = 0;
        
        for (; j < [[result allKeys] count]; j++) {
            
            NSString *crtGroup = [[result allKeys]objectAtIndex:j];
            
            if ([u.group isEqualToString:crtGroup]) {
                
                [[result objectForKey:crtGroup] addObject:u];
                break;
            }
        }
        
        if (j == [[result allKeys] count]) {
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            
            [array addObject:u];
            
            [result setValue:array forKey:u.group];
        }
    }
    
    return result;
}

@end
