//
//  models_Comment.m
//  ravent
//
//  Created by florian haftman on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "models_Comment.h"
#import "ActionDispatcher.h"
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
    
    _isRequesting = YES;
    [self performSelector:@selector(updateLoadingMessage3:) withObject:resourcePath afterDelay:5];
}

- (void)post:(NSMutableDictionary *)params success:(SEL)success failure:(SEL)failure
{
    RKLogConfigureByName("RestKit/*", RKLogLevelTrace);
    _callbackResponseSuccess = success;
    _callbackResponseFailure = failure;
    
    RKParams* rkparams = [RKParams params];
    
    NSString *key = nil;
    int i = 0;
    
    for (; i < [params.allKeys count]; i++) {
        
        key = [params.allKeys objectAtIndex:i];
        
        if ([key isEqualToString:@"attachment"]) {
          
            [rkparams setData:[params valueForKey:@"attachment"] MIMEType:@"image/jpeg" forParam:@"attachment"];
            break;
        }
    }
    
    if ([key isEqualToString:@"attachment"]) {
     
        [params removeObjectForKey:key];
    }
    
    [[RKClient sharedClient] put:[@"/post" appendQueryParams:params] params:rkparams delegate:self];
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
