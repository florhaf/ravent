//
//  models_Comment.h
//  ravent
//
//  Created by florian haftman on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <RestKit/RestKit.h>

@interface models_Comment : NSObject<RKObjectLoaderDelegate> {
    
    id _delegate;
    SEL _callback;
    
    RKObjectManager *_manager;    
    
    NSString *_firstName;
    NSString *_lastName;
    NSString *_message;
    NSString *_pictureUser;
    NSString *_pictureContent;
    NSString *_time;
}

@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *pictureUser;
@property (nonatomic, retain) NSString *pictureContent;
@property (nonatomic, retain) NSString *time;

- (id)initWithDelegate:(NSObject *)del andSelector:(SEL)sel;
- (void)loadFeedWithParams:(NSMutableDictionary *)params;
- (void)cancelAllRequests;

@end
