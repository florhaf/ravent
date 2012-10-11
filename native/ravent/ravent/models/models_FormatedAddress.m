//
//  models_FormatedAddress.m
//  ravent
//
//  Created by florian haftman on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "models_FormatedAddress.h"
#import <RestKit/RKErrorMessage.h>

#define SERVICE_URL @"http://raventsvc.appspot.com"

@implementation models_FormatedAddress

@synthesize formatted_address = _formatted_address;

- (id)initWithEvent:(models_Event *)event delegate:(id)delegate callback:(SEL)callback
{
    self = [super init];
    
    if (self != nil) {
        
        _event = event;
        _delegate = delegate;
        _callback = callback;
    }
    
    return self;
}

- (void)loadAddress
{
    NSString *resourcePath = [NSString stringWithFormat:@"maps/api/geocode/json?latlng=%@,%@&sensor=true", _event.latitude, _event.longitude];
    
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[models_FormatedAddress class]];
    [objectMapping mapKeyPath:@"formatted_address" toAttribute:@"formatted_address"];
    
    if (_manager == nil) {
        
        _manager = [RKObjectManager objectManagerWithBaseURL:@"http://maps.googleapis.com/"];
    }
    
    [_manager.mappingProvider setMapping:objectMapping forKeyPath:@"results"];
    [_manager loadObjectsAtResourcePath:resourcePath objectMapping:objectMapping delegate:self]; 
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

- (void)mydealloc
{
    if (_event) {
        
        [_event mydealloc];
        _event = nil;
    }
    
    [_manager.requestQueue cancelAllRequests];
    _manager = nil;
    _delegate = nil;
    _callback = nil;
}

@end
