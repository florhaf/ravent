//
//  Store.h
//  ravent
//
//  Created by florian haftman on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "models_Event.h"

typedef enum {
    watchlist,
    gemdropped
} listType;

@interface Store : NSObject<NSFetchedResultsControllerDelegate> {
    
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


- (void)save:(models_Event *)event;
- (void)del:(models_Event *)event;
- (NSManagedObject *)managedObjectlookup:(NSString *)eid;
- (NSArray *)managedObjectlookupByDate:(NSDate *)date;
- (models_Event *)lookup:(NSString *)eid;
- (NSMutableArray *)lookupByDate:(NSDate *)date;
- (NSMutableArray *)findFutureEvents;



- (NSFetchedResultsController *)fetchedResultsController;

+ (Store *)instance;

@end
