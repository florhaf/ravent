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

@interface Store : NSObject<NSFetchedResultsControllerDelegate> {
    
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (NSFetchedResultsController *)fetchedResultsController;
- (NSString *)saveEid:(NSString *)eid forDate:(NSString *)startDate;
- (NSString *)saveEvent:(models_Event *)event;
- (NSMutableArray *)findEidsForDate:(NSString *)startDate;
- (NSMutableArray *)findEventsForDate:(NSString *)startDate;

+ (Store *)instance;

@end
