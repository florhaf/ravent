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
    IBOutlet UILabel *_itemTime;
    IBOutlet UILabel *_itemDistance;
}

- (id)initWithUser:(models_User *)user;
- (void)onLoadEvents:(NSArray *)objects;
- (void)loadDataWithUserLocation;
- (void)loadEventDetails:(models_Event *)event;

@end
