//
//  models_Comment.m
//  ravent
//
//  Created by florian haftman on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "models_Comment.h"
#import <RestKit/JSONKit.h>

@implementation models_Comment

@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize pictureUser = _pictureUser;
@synthesize message = _message;
@synthesize pictureContent = _pictureContent;
@synthesize time = _time;
@synthesize uid = _uid;

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


- (void)loadFeedWithParams:(NSMutableDictionary *)params
{
    NSString *resourcePath = [@"comments" appendQueryParams:params];
    
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[models_Comment class]];
    [objectMapping mapKeyPath:@"first_name" toAttribute:@"firstName"];
    [objectMapping mapKeyPath:@"last_name" toAttribute:@"lastName"];
    [objectMapping mapKeyPath:@"picture_user" toAttribute:@"pictureUser"];
    [objectMapping mapKeyPath:@"picture_content" toAttribute:@"pictureContent"];
    [objectMapping mapKeyPath:@"message" toAttribute:@"message"];
    [objectMapping mapKeyPath:@"time" toAttribute:@"time"];
    
    if (_manager == nil) {
        
        _manager = [RKObjectManager objectManagerWithBaseURL:SERVICE_URL];
    }
    
    [_manager.mappingProvider setMapping:objectMapping forKeyPath:@"records"];
    [_manager loadObjectsAtResourcePath:resourcePath objectMapping:objectMapping delegate:self]; 
}

- (void)post:(NSMutableDictionary *)params success:(SEL)success failure:(SEL)failure
{
    _callbackResponseSuccess = success;
    _callbackResponseFailure = failure;
    
    [[RKClient sharedClient] put:[@"post" appendQueryParams:params] params:nil delegate:self];
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    if ([request isGET]) {
        
        return;
    }
    
    if ([response isOK]) {
        
        NSDictionary *responseAsDic = [[response bodyAsString] objectFromJSONString];
        
        if ([[NSString stringWithFormat:@"%@", [responseAsDic valueForKey:@"success"]] isEqualToString:@"0"]) {
         
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:[NSString stringWithFormat:@"%@", [responseAsDic valueForKey:@"message"]] forKey:@"statusCode"];
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [_delegate performSelector:_callbackResponseFailure withObject:dic];
#pragma clang diagnostic pop
        } else {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [_delegate performSelector:_callbackResponseSuccess withObject:[response bodyAsString]];
#pragma clang diagnostic pop   
            
        }
    } else {
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:[NSString stringWithFormat:@"status code: %d", response.statusCode] forKey:@"statusCode"];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_delegate performSelector:_callbackResponseFailure withObject:dic];
#pragma clang diagnostic pop
    }
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

@end
