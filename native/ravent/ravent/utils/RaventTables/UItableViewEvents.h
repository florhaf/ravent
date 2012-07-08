//
//  UItableViewEvents.h
//  ravent
//
//  Created by florian haftman on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UITableViewReloadable.h"

@interface UITableViewEvents : UITableViewReloadable {
    
    IBOutlet UIView *_itemScore;
    IBOutlet UILabel *_itemStartTime;
    IBOutlet UILabel *_itemEndTime;
    IBOutlet UILabel *_itemDistance;
    IBOutlet UILabel *_itemVenueCategory;

    IBOutlet UIImageView *_bg;
    IBOutlet UIImageView *_special;
    IBOutlet UIImageView *_featured;
    IBOutlet UIImageView *_ticket_link;
    
    UIViewController *_details;
    
    
}

- (id)initWithUser:(models_User *)user;
- (void)onLoadEvents:(NSArray *)objects;
- (void)loadDataWithUserLocation;
- (void)loadEventDetails:(models_Event *)event;
- (models_Event *)getEventForSection:(NSInteger)section andRow:(NSInteger)row;

@end
