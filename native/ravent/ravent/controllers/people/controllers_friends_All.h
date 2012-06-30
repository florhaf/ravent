//
//  controllers_friends_All.h
//  ravent
//
//  Created by florian haftman on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECSlidingViewController.h"
#import "UITableViewSearchable.h"

@interface controllers_friends_All : UITableViewSearchable {
    
    NSMutableDictionary *_following;
    IBOutlet UISwitch *_switch;
}

@property (nonatomic, assign) CGFloat peekLeftAmount;
@property (nonatomic, retain) NSMutableDictionary *following;

- (id)initWithUser:(models_User *)user following:(NSMutableDictionary *)following;
- (void)loadData:(BOOL)force;
- (void)onLoadAll:(NSArray *)objects;
- (IBAction)onValueChanged:(id)sender;
- (void)reloadTableViewDataSource:(BOOL)force;
- (BOOL)contains:(NSMutableDictionary *)array user:(models_User *)u;

+ (controllers_friends_All *)instance:(NSMutableDictionary *)following;
+ (void)release;

@end
