//
//  Store.m
//  ravent
//
//  Created by florian haftman on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Store.h"

@implementation Store

@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;

static Store *_store;


//- (NSString *)getStoreDateStringFrom:(NSString *)eventDate
//{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
//    
//    NSDate *date = [dateFormatter dateFromString:eventDate];
//    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
//    NSString *dateStr = [NSString stringWithFormat:@"%d-%d-%d", components.year, components.month, components.day];
//    return dateStr;
//}
//
//- (NSDate *)getDateFromStoreString:(NSString *)storeString
//{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"YYYY-MM-DD"];
//    
//    return [dateFormatter dateFromString:storeString];
//}


- (void)save:(models_Event *)event
{
    [self del:event];
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    [newManagedObject setValue:event.dateStart forKey:@"startDate"];
    [newManagedObject setValue:event.dateEnd forKey:@"endDate"];
    [newManagedObject setValue:event.eid forKey:@"eid"];
    [newManagedObject setValue:[[NSNumber alloc] initWithBool:event.isInWatchList] forKey:@"isInWatchList"];
    [newManagedObject setValue:[[NSNumber alloc] initWithBool:event.isGemDropped] forKey:@"isGemDropped"];
    [newManagedObject setValue:[[NSNumber alloc] initWithBool:event.isSyncedWithCal] forKey:@"isSyncedWithCal"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        NSLog(@"%@", error.localizedDescription);
    }
}

- (void)del:(models_Event *)event
{
    NSManagedObject *mo = [self managedObjectlookup:event.eid];
    
    if (mo != nil) {
     
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:mo];
    }
}

- (NSManagedObject *)managedObjectlookup:(NSString *)eid
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:[self managedObjectContext]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(eid = %@)", eid];
    
    [request setEntity:entityDesc];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *objects = [[self managedObjectContext] executeFetchRequest:request error:&error];

    if (objects != nil && [objects count] > 0) {
        
        return [objects objectAtIndex:0];
    }
    
    return nil;
}

- (NSArray *)managedObjectlookupByDate:(NSDate *)date
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:[self managedObjectContext]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, yyyy"];
    NSString *strFromDate = [dateFormatter stringFromDate:date];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(endDate = %@)", strFromDate];
    
    [request setEntity:entityDesc];
    [request setPredicate:pred];
    
    NSError *error;
    return [[self managedObjectContext] executeFetchRequest:request error:&error];
}

- (models_Event *)lookup:(NSString *)eid
{
    NSManagedObject *mo = [self managedObjectlookup:eid];
    
    if (mo != nil) {
        
        models_Event *e = [[models_Event alloc] init];
     
        e.eid = [mo valueForKey:@"eid"];
        e.dateStart = [mo valueForKey:@"startDate"];
        e.dateEnd = [mo valueForKey:@"endDate"];
        e.isInWatchList = [((NSNumber *)[mo valueForKey:@"isInWatchList"]) boolValue];
        e.isGemDropped = [((NSNumber *)[mo valueForKey:@"isGemDropped"]) boolValue];
        
        return e;
    }
    
    return nil;
}

- (NSMutableArray *)lookupByDate:(NSDate *)date
{
    NSArray *mos = [self managedObjectlookupByDate:date];
    NSMutableArray *res = [[NSMutableArray alloc] init];
    
    for (NSManagedObject *mo in mos) {
        
        models_Event *e = [[models_Event alloc] init];

        e.eid = [mo valueForKey:@"eid"];
        e.dateStart = [mo valueForKey:@"startDate"];
        e.dateEnd = [mo valueForKey:@"endDate"];
        e.isInWatchList = [((NSNumber *)[mo valueForKey:@"isInWatchList"]) boolValue];
        e.isGemDropped = [((NSNumber *)[mo valueForKey:@"isGemDropped"]) boolValue];
        
        [res addObject:e];
    }
    
    return res;
}

- (NSMutableArray *)findFutureEvents
{
    NSDate *start = [NSDate date];
    NSDate *end = [start dateByAddingTimeInterval:60 * 60 * 24 * 31 * 6];
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    while ([start compare:end] != NSOrderedDescending) {
        
        [results addObjectsFromArray:[self lookupByDate:start]];
        
        start = [start dateByAddingTimeInterval:60 * 60 * 24];
    }
    
    return results;
}



















#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {

	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
    
    return __fetchedResultsController;
}  

+ (Store *)instance
{
    if (_store == nil) {
        
        _store = [[Store alloc] init];
    }
    
    return _store;
}

@end
