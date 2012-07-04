//
//  models_User.m
//  ravent
//
//  Created by florian haftman on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "models_User.h"
#import "ActionDispatcher.h"
#import "GPSManager.h"
#import <RestKit/RKErrorMessage.h>

@implementation models_User

@synthesize delegate = _delegate;
@synthesize callback = _callback;
@synthesize callbackResponseSuccess = _callbackResponseSuccess;
@synthesize callbackResponseFailure = _callbackResponseFailure;

//@synthesize locationManager = _locationManager;
@synthesize locationDelegate = _locationDelegate;
@synthesize locationSuccess = _locationSuccess;
@synthesize locationFailure = _locationFailure;

@synthesize uid = _uid;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize picture = _picture;
@synthesize pic_small = _pic_small;
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
@synthesize searchRadius = _searchRadius;
@synthesize searchWindow = _searchWindow;

//#define SERVICE_URL @"http://air.local:8888"
#define SERVICE_URL @"http://raventsvc.appspot.com"

#define LOCATION_UPDATE_INTERVAL 2

static NSArray* _allListSingleton = nil;
static models_User *_crtUser = nil;

- (id)init
{
    self = [super init];
    
    if (self != nil) {
        
//        _locationManager = [[CLLocationManager alloc] init];
//        _locationManager.delegate = self;
    }
    
    return self;
}

- (void)saveToNSUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:_uid forKey:@"_uid"];
    [defaults setObject:_firstName forKey:@"_firstName"];
    [defaults setObject:_lastName forKey:@"_lastName"];
    [defaults setObject:_picture forKey:@"_picture"];
    [defaults setObject:_accessToken forKey:@"_accessToken"];
    [defaults setObject:[NSNumber numberWithInt:_searchRadius] forKey:@"_searchRadius"];
    [defaults setObject:[NSNumber numberWithInt:_searchWindow] forKey:@"_searchWindow"];
    [defaults synchronize];
}

- (void)delFromNSUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:@"_uid"];
    [defaults removeObjectForKey:@"_firstName"];
    [defaults removeObjectForKey:@"_lastName"];
    [defaults removeObjectForKey:@"_picture"];
    [defaults removeObjectForKey:@"_accessToken"];
    [defaults removeObjectForKey:@"_searchRadius"];
    [defaults removeObjectForKey:@"_searchWindow"];
    [defaults synchronize];
}

- (void)loadFromNSUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.uid = [defaults objectForKey:@"_uid"];
    self.firstName = [defaults objectForKey:@"_firstName"];
    self.lastName = [defaults objectForKey:@"_lastName"];
    self.picture = [defaults objectForKey:@"_picture"];
    self.accessToken = [defaults objectForKey:@"_accessToken"];
    self.searchRadius = [((NSNumber *)[defaults objectForKey:@"_searchRadius"]) intValue];
    self.searchWindow = [((NSNumber *)[defaults objectForKey:@"_searchWindow"]) intValue];
}

- (id)initWithDelegate:(NSObject *)del andSelector:(SEL)sel
{
    self = [super init];
    if (self != nil) {
        
        _delegate = del;
        _callback = sel;
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
    another.searchRadius = _searchRadius;
    another.searchWindow = _searchWindow;
    
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
    _crtUser.searchWindow = 48;
    _crtUser.searchRadius = 15;
    _crtUser.timeZone = [NSString stringWithFormat:@"%d", [[NSTimeZone localTimeZone] secondsFromGMT] / 60 ];
    _crtUser.accessToken = u.accessToken;

    return _crtUser;
}

+ (models_User *)crtUser
{
    return _crtUser;
}

+ (void)release
{

}

- (void)getLocation
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGPSDone) name:GPSDone object:[GPSManager instance]];
    [[GPSManager instance] startGps];
}

- (void)onGPSDone
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GPSDone object:[GPSManager instance]];
    
    NSError *error = [GPSManager instance].error;
    
    if (error == nil) {
        
        [models_User crtUser].latitude = [NSString stringWithFormat:@"%f", [GPSManager instance].currentLocation.coordinate.latitude];
        [models_User crtUser].longitude = [NSString stringWithFormat:@"%f", [GPSManager instance].currentLocation.coordinate.longitude];
    }
    
    [self dispatchLocation:error];
}

- (void)dispatchLocation:(NSError *)error
{

    if (error != nil) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_locationDelegate performSelector:_locationFailure withObject:error];
#pragma clang diagnostic pop
    } else {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_locationDelegate performSelector:_locationSuccess];
#pragma clang diagnostic pop
    }
}

- (void)loadUser
{
    //RKLogConfigureByName("RestKit/*", RKLogLevelTrace);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:_uid forKey:@"userID"];
    
    if (_accessToken == nil || [_accessToken isEqualToString:@""]) {
     
        // load a friend
        [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
    } else {
        
        // load crt user
        [params setValue:_accessToken forKey:@"access_token"];
        [params setValue:@"yes" forKey:@"appuser"];
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
    
    _isRequesting = YES;
    [self performSelector:@selector(updateLoadingMessage3:) withObject:resourcePath afterDelay:5];
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
    
    _isRequesting = YES;
    [self performSelector:@selector(updateLoadingMessage3:) withObject:resourcePath afterDelay:5];
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
    
    _isRequesting = YES;
    [self performSelector:@selector(updateLoadingMessage3:) withObject:resourcePath afterDelay:5];
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
    
    _isRequesting = YES;
    [self performSelector:@selector(updateLoadingMessage3:) withObject:resourcePath afterDelay:5];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    
    if (objects != nil && [objects count] > 0) {
        
        id obj = [objects objectAtIndex:0];
        
        if ([obj isKindOfClass:[RKErrorMessage class]]) {
            
            RKErrorMessage *rkErr = (RKErrorMessage *) obj;
            NSError *nsErr = [NSError errorWithDomain:rkErr.errorMessage code:42 userInfo:nil];
            
            objects = [[NSArray alloc] initWithObjects:nsErr, nil];
        }
    }
        
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray* sortedObjects = [objects sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    if ([objectLoader.URL.path rangeOfString:@"friends"].location != NSNotFound) {
        
        _allListSingleton = [[NSArray alloc] initWithArray:sortedObjects];
    }
    
    if (_delegate == nil) {
        
        return;
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
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateLoadingMessage:) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateLoadingMessage2:) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateLoadingMessage3:) object:nil];
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
    RKLogConfigureByName("RestKit/*", RKLogLevelTrace);
    _callbackResponseSuccess = success;
    _callbackResponseFailure = failure;
    _sender = sender;
    
    [[RKClient sharedClient] delete:[@"followings" appendQueryParams:params] delegate:self];
}

- (void)updateLoadingMessage:(NSString *)resourcePath
{
    [[ActionDispatcher instance] execute:resourcePath withString:@"Loading..."];
    [self performSelector:@selector(updateLoadingMessage2:) withObject:resourcePath afterDelay:10];
}

- (void)updateLoadingMessage2:(NSString *)resourcePath
{
    [[ActionDispatcher instance] execute:resourcePath withString:@"Still loading..."];
}

- (void)updateLoadingMessage3:(NSString *)resourcePath
{
    if (_isRequesting) {
        
        [[ActionDispatcher instance] execute:resourcePath withString:@"Waiting for server..."];
    }
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    _isRequesting = NO;
    [[ActionDispatcher instance] execute:request.resourcePath withString:@"Got a response..."];
    
    [self performSelector:@selector(updateLoadingMessage:) withObject:request.resourcePath afterDelay:2];
    
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
    
    if (data == nil) {
        
        return result;
    }
    
    for (int i = 0; i < [data count]; i++) {
        
        models_User *u = [data objectAtIndex:i];
        
        u.group = [u.lastName substringToIndex:1];
        u.group = [NSString stringWithFormat:@"%@%@",[[u.group substringToIndex:1] uppercaseString],[u.group substringFromIndex:1] ];
        
        u.pic_small = [u.picture stringByReplacingOccurrencesOfString:@"_n.jpg" withString:@"_s.jpg"];
        
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

- (void)dealloc
{
    [self cancelAllRequests];
    self.delegate = nil;
    self.locationDelegate = nil;
    _sender = nil;
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GPSDone object:[GPSManager instance]];
}

@end
