//
//  models_Event.m
//  ravent
//
//  Created by florian haftman on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "models_Event.h"
#import "models_User.h"
#import "ActionDispatcher.h"
#import "Store.h"
#import <RestKit/RKERrorMessage.h>

@implementation models_Event

@synthesize delegate = _delegate;
@synthesize callback = _callback;
@synthesize callbackResponseSuccess = _callbackResponseSuccess;
@synthesize callbackResponseFailure = _callbackResponseFailure;
@synthesize eid = _eid;
@synthesize name = _name;
@synthesize location = _location;
@synthesize venue_category = _venue_category;
@synthesize pic_big = _pic_big;
@synthesize pic_small = _pic_small;
@synthesize score = _score;
@synthesize timeStart = _timeStart;
@synthesize timeEnd = _timeEnd;
@synthesize distance = _distance;
@synthesize group = _group;
@synthesize description = _description;
@synthesize dateStart = _dateStart;
@synthesize dateEnd = _dateEnd;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize groupTitle = _groupTitle;
@synthesize coordinate = _coordinate;
@synthesize filter = _filter;
@synthesize female_ratio = _female_ratio;
@synthesize male_ratio = _male_ratio;
@synthesize nb_attending = _nb_attending;
@synthesize rsvp_status = _rsvp_status;
@synthesize offerTitle = _offerTitle;
@synthesize offerDescription = _offerDescription;
@synthesize featured = _featured;
@synthesize ticket_link = _ticket_link;
@synthesize isGemDropped = _isGemDropped;
@synthesize isInWatchList = _isInWatchList;
@synthesize isSyncedWithCal = _isSyncedWithCal;
@synthesize address = _address;

//#define SERVICE_URL @"http://air.local:8888"
#define SERVICE_URL @"http://raventsvc.appspot.com"

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
    models_Event *another = [[models_Event alloc] init];
    
    another.eid = _eid;
    another.name = _name;
    another.location = _location;
    another.venue_category = _venue_category;
    another.pic_big = _pic_big;
    another.score = _score;
    another.timeStart = _timeStart;
    another.timeEnd = _timeEnd;
    another.distance = _distance;
    another.group = _group;
    another.description = _description;
    another.dateStart = _dateStart;
    another.dateEnd = _dateEnd;
    another.latitude = _latitude;
    another.longitude = _longitude;
    another.groupTitle = _groupTitle;
    another.coordinate = _coordinate;
    another.filter = _filter;
    another.rsvp_status = _rsvp_status;
    another.offerTitle = _offerTitle;
    another.offerDescription = _offerDescription;
    another.ticket_link = _ticket_link;
    another.featured = _featured;
    another.isInWatchList = _isInWatchList;
    another.isGemDropped = _isGemDropped;
    another.isSyncedWithCal = _isSyncedWithCal;
    another.address = _address;
    
    return another;
}

- (void)loadEventsWithParams:(NSMutableDictionary *)params
{
        //RKLogConfigureByName("RestKit/*", RKLogLevelTrace);
    NSString *resourcePath = [@"events" appendQueryParams:params];
       
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[models_Event class]];
    [objectMapping mapKeyPath:@"eid" toAttribute:@"eid"];
    [objectMapping mapKeyPath:@"name" toAttribute:@"name"];
    [objectMapping mapKeyPath:@"location" toAttribute:@"location"];
    [objectMapping mapKeyPath:@"venue_category" toAttribute:@"venue_category"];
    [objectMapping mapKeyPath:@"pic_big" toAttribute:@"pic_big"];
    [objectMapping mapKeyPath:@"score" toAttribute:@"score"];
    [objectMapping mapKeyPath:@"time_start" toAttribute:@"timeStart"];
    [objectMapping mapKeyPath:@"time_end" toAttribute:@"timeEnd"];
    [objectMapping mapKeyPath:@"distance" toAttribute:@"distance"];
    [objectMapping mapKeyPath:@"group" toAttribute:@"group"];
    [objectMapping mapKeyPath:@"date_start" toAttribute:@"dateStart"];
    [objectMapping mapKeyPath:@"date_end" toAttribute:@"dateEnd"];
    [objectMapping mapKeyPath:@"latitude" toAttribute:@"latitude"];
    [objectMapping mapKeyPath:@"longitude" toAttribute:@"longitude"];
    [objectMapping mapKeyPath:@"groupTitle" toAttribute:@"groupTitle"];
    [objectMapping mapKeyPath:@"filter" toAttribute:@"filter"];
    [objectMapping mapKeyPath:@"offer_title" toAttribute:@"offerTitle"];
    [objectMapping mapKeyPath:@"offer_description" toAttribute:@"offerDescription"];
    [objectMapping mapKeyPath:@"featured" toAttribute:@"featured"];
    [objectMapping mapKeyPath:@"ticket_link" toAttribute:@"ticket_link"];

    if (_manager == nil) {
        
        _manager = [RKObjectManager objectManagerWithBaseURL:SERVICE_URL];
    }
    
    [_manager.mappingProvider setMapping:objectMapping forKeyPath:@"records"];
    [_manager loadObjectsAtResourcePath:resourcePath objectMapping:objectMapping delegate:self];
    
    _isRequesting = YES;
    [self performSelector:@selector(updateLoadingMessage3:) withObject:resourcePath afterDelay:5];
}

- (void)reloadWithParams:(NSMutableDictionary *)params
{
    
    //RKLogConfigureByName("RestKit/*", RKLogLevelTrace);
    NSString *resourcePath = [@"calendar" appendQueryParams:params];
    
    Store *store = [Store instance];
    NSMutableArray *events = [[NSMutableArray alloc] init];
    
    [events addObjectsFromArray:[store findFutureEvents]];
    
    
    for (int i = 0; i < [events count]; i++) {
        
        resourcePath = [NSString stringWithFormat:@"%@&eventID=%@", resourcePath, ((models_Event *)[events objectAtIndex:i]).eid];
    }
    
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[models_Event class]];
    [objectMapping mapKeyPath:@"eid" toAttribute:@"eid"];
    [objectMapping mapKeyPath:@"name" toAttribute:@"name"];
    [objectMapping mapKeyPath:@"location" toAttribute:@"location"];
    [objectMapping mapKeyPath:@"venue_category" toAttribute:@"venue_category"];
    [objectMapping mapKeyPath:@"pic_big" toAttribute:@"pic_big"];
    [objectMapping mapKeyPath:@"score" toAttribute:@"score"];
    [objectMapping mapKeyPath:@"time_start" toAttribute:@"timeStart"];
    [objectMapping mapKeyPath:@"time_end" toAttribute:@"timeEnd"];
    [objectMapping mapKeyPath:@"distance" toAttribute:@"distance"];
    [objectMapping mapKeyPath:@"group" toAttribute:@"group"];
    [objectMapping mapKeyPath:@"date_start" toAttribute:@"dateStart"];
    [objectMapping mapKeyPath:@"date_end" toAttribute:@"dateEnd"];
    [objectMapping mapKeyPath:@"latitude" toAttribute:@"latitude"];
    [objectMapping mapKeyPath:@"longitude" toAttribute:@"longitude"];
    [objectMapping mapKeyPath:@"groupTitle" toAttribute:@"groupTitle"];
    [objectMapping mapKeyPath:@"filter" toAttribute:@"filter"];
    [objectMapping mapKeyPath:@"offer_title" toAttribute:@"offerTitle"];
    [objectMapping mapKeyPath:@"offer_description" toAttribute:@"offerDescription"];
    [objectMapping mapKeyPath:@"featured" toAttribute:@"featured"];
    [objectMapping mapKeyPath:@"ticket_link" toAttribute:@"ticket_link"];
    
    if (_manager == nil) {
        
        _manager = [RKObjectManager objectManagerWithBaseURL:SERVICE_URL];
    }
    
    [_manager.mappingProvider setMapping:objectMapping forKeyPath:@"records"];
    [_manager loadObjectsAtResourcePath:resourcePath objectMapping:objectMapping delegate:self];
    
    _isRequesting = YES;
    [self performSelector:@selector(updateLoadingMessage3:) withObject:resourcePath afterDelay:5];
}

- (void)loadDescription
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
    [params setValue:_eid forKey:@"eid"];
    
    NSString *resourcePath = [@"description" appendQueryParams:params];
    
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[models_Event class]];
    [objectMapping mapKeyPath:@"description" toAttribute:@"description"];
    
    if (_manager == nil) {
        
        _manager = [RKObjectManager objectManagerWithBaseURL:SERVICE_URL];
    }
    
    [_manager.mappingProvider setMapping:objectMapping forKeyPath:@"records"];
    [_manager loadObjectsAtResourcePath:resourcePath objectMapping:objectMapping delegate:self];  
    
    _isRequesting = YES;
    [self performSelector:@selector(updateLoadingMessage3:) withObject:resourcePath afterDelay:5];
}

- (void)loadStatsWithParams:(NSMutableDictionary *)params andTarget:(id)target andSelector:(SEL)success
{
    NSString *resourcePath = [@"eventstats" appendQueryParams:params];
    
    _callbackStatsSuccess = success;
    _senderStats = target;
    
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[models_Event class]];
    [objectMapping mapKeyPath:@"female_ratio" toAttribute:@"female_ratio"];
    [objectMapping mapKeyPath:@"male_ratio" toAttribute:@"male_ratio"];
    [objectMapping mapKeyPath:@"nb_attending" toAttribute:@"nb_attending"];
    
    if (_manager == nil) {
        
        _manager = [RKObjectManager objectManagerWithBaseURL:SERVICE_URL];
    }
    
    [_manager.mappingProvider setMapping:objectMapping forKeyPath:@"records"];
    [_manager loadObjectsAtResourcePath:resourcePath objectMapping:objectMapping delegate:self];
}

- (void)loadRsvpWithParams:(NSMutableDictionary *)params andTarget:(id)target andSelector:(SEL)success
{
    NSString *resourcePath = [@"rsvp" appendQueryParams:params];
    
    _callbackRsvpSuccess = success;
    _senderRsvp = target;
    
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[models_Event class]];
    [objectMapping mapKeyPath:@"rsvp_status" toAttribute:@"rsvp_status"];
    
    if (_manager == nil) {
        
        _manager = [RKObjectManager objectManagerWithBaseURL:SERVICE_URL];
    }
    
    [_manager.mappingProvider setMapping:objectMapping forKeyPath:@"records"];
    [_manager loadObjectsAtResourcePath:resourcePath objectMapping:objectMapping delegate:self];
}

- (void)vote:(NSMutableDictionary *)params success:(SEL)success failure:(SEL)failure sender:(id)sender
{
    _callbackResponseSuccess = success;
    _callbackResponseFailure = failure;
    _sender = sender;
    
    [[RKClient sharedClient] put:[@"vote" appendQueryParams:params] params:nil delegate:self];
}

- (void)rsvp:(NSMutableDictionary *)params success:(SEL)success failure:(SEL)failure sender:(id)sender
{
    _callbackResponseSuccess = success;
    _callbackResponseFailure = failure;
    _sender = sender;
    
    [[RKClient sharedClient] put:[@"rsvp" appendQueryParams:params] params:nil delegate:self];
}

- (void)share:(NSMutableDictionary *)params
{
    [[RKClient sharedClient] put:[@"share" appendQueryParams:params] params:nil delegate:self];
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
    
    if ([objectLoader.URL.path rangeOfString:@"eventstats"].location != NSNotFound) {
        
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_senderStats performSelector:_callbackStatsSuccess withObject:objects];
    #pragma clang diagnostic pop
        
        return;
    }
    
    if ([objectLoader.URL.path rangeOfString:@"rsvp"].location != NSNotFound) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_senderRsvp performSelector:_callbackRsvpSuccess withObject:objects];
#pragma clang diagnostic pop
        
        return;
    }
    
    
    if (_delegate != nil && [_delegate respondsToSelector:_callback]) {
        
     
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_delegate performSelector:_callback withObject:objects];
#pragma clang diagnostic pop
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    NSArray *objects = [[NSArray alloc] initWithObjects:error, nil];
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_delegate performSelector:_callback withObject:objects];
    #pragma clang diagnostic pop
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
     
        [[ActionDispatcher instance] execute:resourcePath withString:@"Analyzing data..."];
    }
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    _isRequesting = NO;
    
    [[ActionDispatcher instance] execute:request.resourcePath withString:@"Loading..."];
    
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

- (void)cancelAllRequests
{
    [[_manager requestQueue] cancelAllRequests];
    
    _isRequesting = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateLoadingMessage:) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateLoadingMessage2:) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateLoadingMessage3:) object:nil];
}

+ (NSMutableDictionary *)getGroupedData:(NSArray *)data
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    if (data == nil) {
        
        return result;
    }
    
    for (int i = 0; i < [data count]; i++) {
        
        models_Event *e = [data objectAtIndex:i];
        NSString *group = e.group;
        e.pic_small = [e.pic_big stringByReplacingOccurrencesOfString:@"_n.jpg" withString:@"_s.jpg"];
        
        int j = 0;
        
        for (; j < [result count]; j++) {
            
            NSString *crtGroup = [[result allKeys]objectAtIndex:j];
            
            if ([group isEqualToString:crtGroup]) {
                
                [[result objectForKey:crtGroup] addObject:e];
                break;
            }
        }
        
        if (j == [result count]) {
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [array addObject:e];
            
            //group = (group == nil) ? @"?" : group;
            
            if (group != nil) {
             
                [result setObject:array forKey:group];
            }
        }
    }
    
    return result;
}

- (NSString *)title
{    
    return _location;
}

- (NSString *)subtitle
{    
    return _address;
}

- (void)dealloc
{
    [self cancelAllRequests];
    
    _delegate = nil;
    _callback = nil;
    
    // callback for raw response
    _callbackResponseSuccess = nil;
    _callbackResponseFailure = nil;
    _sender = nil;
    
    _callbackStatsSuccess = nil;
    _callbackStatsFailure = nil;
    _senderStats = nil;
    
    _callbackRsvpSuccess = nil;
    _callbackRsvpFailure = nil;
    _senderRsvp = nil;
    
    _manager = nil;
    
    _eid = nil;
    _name = nil;
    _location = nil;
    _venue_category = nil;
    _pic_big = nil;
    _pic_small = nil;
    _score = nil;
    _timeStart = nil;
    _timeEnd = nil;
    _distance = nil;
    _group = nil;
    _description = nil;
    _dateStart = nil;
    _dateEnd = nil;
    _latitude = nil;
    _longitude = nil;
    _groupTitle = nil;
    _filter = nil;
    _female_ratio = nil;
    _male_ratio = nil;
    _nb_attending = nil;
    _rsvp_status = nil;
    
    _offerTitle = nil;
    _offerDescription = nil;
    _featured = nil;
    _ticket_link = nil;
}

@end
