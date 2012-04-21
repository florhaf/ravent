//
//  controllers_friends_All.h
//  ravent
//
//  Created by florian haftman on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECSlidingViewController.h"
#import "UITableViewReloadable.h"

@interface controllers_friends_All : UITableViewReloadable<UISearchBarDelegate> {
    
    NSMutableDictionary *_following;
    UISearchBar *_searchBar;
    IBOutlet UISwitch *_switch;
}

@property (nonatomic, unsafe_unretained) CGFloat peekLeftAmount;

- (id)initWithUser:(models_User *)user following:(NSMutableDictionary *)following;
- (void)loadData:(BOOL)force;
- (void)onLoadAll:(NSArray *)objects;
- (IBAction)onValueChanged:(id)sender;

@end
