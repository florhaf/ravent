//
//  controllers_events_List_p2p.h
//  ravent
//
//  Created by florian haftman on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UItableViewEvents.h"

typedef enum {
    byScore,
    byDistance,
    byTime
} sort;

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
    
    sort _sort;
    
    CLLocationCoordinate2D _searchCenter;
}

@property (nonatomic, retain) NSMutableArray *party;
@property (nonatomic, retain) NSMutableArray *chill;
@property (nonatomic, retain) NSMutableArray *art;
@property (nonatomic, retain) NSMutableArray *other;
@property (nonatomic, assign) sort sort;
@property (nonatomic, assign) CLLocationCoordinate2D searchCenter;

- (void)reloadTableViewDataSourceWithIndex:(int)index;
- (void)sortByScore;
- (void)sortByDistance;
- (void)sortByTime;

+ (controllers_events_List_p2p *)instance;
+ (BOOL)isIntanciated;
+ (void)deleteInstance;

@end
