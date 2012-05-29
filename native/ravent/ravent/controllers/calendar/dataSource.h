//
//  dataSource.h
//  ravent
//
//  Created by florian haftman on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Kal.h"
#import "models_Event.h"
#import "UItableViewEvents.h"

@interface dataSource : NSObject<KalDataSource> {
    
    NSMutableArray *items;
    NSMutableArray *events;
    NSMutableData *buffer;
    id<KalDataSourceCallbacks> callback;
    //BOOL dataReady;
    
    models_Event *_event;
    NSArray *_data;
    
    IBOutlet UIView *_item;
    IBOutlet UILabel *_name;
    IBOutlet UILabel *_location;
    IBOutlet JBAsyncImageView *_picture;
}

@property (nonatomic, assign) BOOL dataReady;

+ (dataSource *)dataSource;
- (models_Event *)eventAtIndexPath:(NSIndexPath *)indexPath;  // exposed for HolidayAppDelegate so that it can implement the UITableViewDelegate protocol.

@end
