//
//  controllers_friends_All.h
//  ravent
//
//  Created by florian haftman on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UITableViewReloadable.h"

@interface controllers_friends_All : UITableViewReloadable {
    
    NSMutableDictionary *_following;
    
    IBOutlet UISwitch *_switch;
}

- (id)initWithUser:(models_User *)user following:(NSMutableDictionary *)following;
- (void)loadData:(BOOL)force;
- (void)onLoadAll:(NSArray *)objects;
- (IBAction)onValueChanged:(id)sender;

@end
