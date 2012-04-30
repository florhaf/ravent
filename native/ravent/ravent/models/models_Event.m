//
//  models_Event.m
//  ravent
//
//  Created by florian haftman on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "models_Event.h"
#import "models_User.h"

@implementation models_Event

@synthesize delegate = _delegate;
@synthesize callback = _callback;
@synthesize eid = _eid;
@synthesize name = _name;
@synthesize location = _location;
@synthesize picture = _picture;
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
    another.picture = _picture;
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
    
    return another;
}

- (void)loadEventsWithParams:(NSMutableDictionary *)params
{
    NSString *resourcePath = [@"events" appendQueryParams:params];
       
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[models_Event class]];
    [objectMapping mapKeyPath:@"eid" toAttribute:@"eid"];
    [objectMapping mapKeyPath:@"name" toAttribute:@"name"];
    [objectMapping mapKeyPath:@"location" toAttribute:@"location"];
    [objectMapping mapKeyPath:@"picture" toAttribute:@"picture"];
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

    if (_manager == nil) {
        
        _manager = [RKObjectManager objectManagerWithBaseURL:SERVICE_URL];
    }
    
    [_manager.mappingProvider setMapping:objectMapping forKeyPath:@"records"];
    [_manager loadObjectsAtResourcePath:resourcePath objectMapping:objectMapping delegate:self]; 
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
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{  
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_delegate performSelector:_callback withObject:objects];
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
}

+ (NSMutableDictionary *)getGroupedData:(NSArray *)data
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < [data count]; i++) {
        
        models_Event *e = [data objectAtIndex:i];
        NSString *group = e.group;
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
            [result setObject:array forKey:group];
        }
    }
    
    return result;
}

- (NSString *)title
{    
    if ([_name isKindOfClass:[NSNull class]]) {
     
        return @"Unknown charge";
    } else {
        
        if ([_name length] > 23) {
            
             return [NSString stringWithFormat:@"%@...", [_name substringToIndex:23]];       
        } else {
            
            return _name;
        }
    }
}

- (NSString *)subtitle
{    
    return _location;
}

@end
