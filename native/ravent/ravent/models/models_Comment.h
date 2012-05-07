//
//  models_Comment.h
//  ravent
//
//  Created by florian haftman on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <RestKit/RestKit.h>

@interface models_Comment : NSObject<RKObjectLoaderDelegate, RKRequestDelegate> {
    
    id _delegate;
    SEL _callback;
    // callback for raw response
    SEL _callbackResponseSuccess;
    SEL _callbackResponseFailure;
    
    RKObjectManager *_manager;    
    
    NSString *_firstName;
    NSString *_lastName;
    NSString *_message;
    NSString *_pictureUser;
    NSString *_pictureContent;
    NSString *_time;
    NSString *_uid;
}

@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *pictureUser;
@property (nonatomic, retain) NSString *pictureContent;
@property (nonatomic, retain) NSString *time;
@property (nonatomic, retain) NSString *uid;

- (id)initWithDelegate:(NSObject *)del andSelector:(SEL)sel;
- (void)loadFeedWithParams:(NSMutableDictionary *)params;
- (void)cancelAllRequests;
- (void)post:(NSMutableDictionary *)params success:(SEL)success failure:(SEL)failure;

@end
