//
//  controllers_events_List_p2p.h
//  ravent
//
//  Created by florian haftman on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UItableViewEvents.h"

@interface controllers_events_List_p2p : UITableViewEvents {
    
    NSMutableArray *_party;
    NSMutableArray *_chill;
    NSMutableArray *_art;
    NSMutableArray *_other;
    
    NSArray *_sortedKeysParty;
    NSArray *_sortedKeysChill;
    NSArray *_sortedKeysArt;
    NSArray *_sortedKeysOther;
    
    NSMutableDictionary *_groupedParty;
    NSMutableDictionary *_groupedChill;
    NSMutableDictionary *_groupedArt;
    NSMutableDictionary *_groupedOther;
}

@property (nonatomic, retain) NSMutableArray *party;
@property (nonatomic, retain) NSMutableArray *chill;
@property (nonatomic, retain) NSMutableArray *art;
@property (nonatomic, retain) NSMutableArray *other;

- (void)reloadTableViewDataSourceWithIndex:(int)index;
- (void)reloadTableViewDataSourceWithNoFadeWithIndex:(int)index;

+ (controllers_events_List_p2p *)instance;
+ (void)release;

@end
