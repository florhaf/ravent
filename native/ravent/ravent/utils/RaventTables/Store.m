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

- (NSString *)saveEid:(NSString *)eid forDate:(NSString *)startDate
{
    NSMutableArray *array = [self findEidsForDate:startDate];
    
    if (array != nil) {
     
        for (int i = 0; i < [array count]; i++) {
            
            NSString *e = [array objectAtIndex:i];
            
            if ([e isEqualToString:eid]) {
                
                return @"event already in your Watchlist";
            }
        }
    }
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:startDate forKey:@"startDate"];
    [newManagedObject setValue:eid forKey:@"eid"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {

        return error.localizedDescription;
    }
    
    return @"event added to your Watchlist";
}

- (NSString *)saveEvent:(models_Event *)event
{
    NSMutableArray *array = [self findEidsForDate:event.dateStart];
    
    for (int i = 0; i < [array count]; i++) {
        
        NSString *eid = [array objectAtIndex:i];
        
        if ([eid isEqualToString:event.eid]) {
            
            return @"event already in your Watchlist";
        }
    }
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:event.dateStart forKey:@"startDate"];
    [newManagedObject setValue:event.dateEnd forKey:@"endDate"];
    [newManagedObject setValue:event.timeStart forKey:@"startTime"];
    [newManagedObject setValue:event.timeEnd forKey:@"endTime"];
    [newManagedObject setValue:event.eid forKey:@"eid"];
    [newManagedObject setValue:event.name forKey:@"name"];
    [newManagedObject setValue:event.location forKey:@"location"];
    [newManagedObject setValue:event.latitude forKey:@"latitude"];
    [newManagedObject setValue:event.longitude forKey:@"longitude"];
    [newManagedObject setValue:event.pic_big forKey:@"picture"];
//    [newManagedObject setValue:event.pic_big forKey:@"isInWatchList"];
//    [newManagedObject setValue:[event.isGemDroppedje ] forKey:@"isGemDropped"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        return error.localizedDescription;
    }
    
    return @"event added to your Watchlist";
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

- (NSMutableArray *)findEidsForDate:(NSString *)startDate
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:[self managedObjectContext]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(startDate = %@)", startDate];
    
    [request setEntity:entityDesc];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *objects = [[self managedObjectContext] executeFetchRequest:request error:&error];
        
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [objects count]; i++) {
            
        NSManagedObject *matche = [objects objectAtIndex:i];
            
        [result addObject:[matche valueForKey:@"eid"]];
    }

    return result;
}

- (NSMutableArray *)findFutureEvents
{
    NSDate *start = [NSDate date];
    NSDate *end = [start dateByAddingTimeInterval:60 * 60 * 24 * 31 * 6];
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    while ([start compare:end] != NSOrderedDescending) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM d, yyyy"];
        NSString *strFromDate = [dateFormatter stringFromDate:start];
        
        [results addObjectsFromArray:[self findEventsForDate:strFromDate]];
        
        start = [start dateByAddingTimeInterval:60 * 60 * 24];
    }
    
    return results;
}

- (NSMutableArray *)findEventsForDate:(NSString *)startDate
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:[self managedObjectContext]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(endDate = %@)", startDate];
    
    [request setEntity:entityDesc];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *objects = [[self managedObjectContext] executeFetchRequest:request error:&error];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    if (objects != nil) {
     
        for (int i = 0; i < [objects count]; i++) {
            
            NSManagedObject *match = [objects objectAtIndex:i];
            
            models_Event *e = [[models_Event alloc] init];
            
            e.eid = [match valueForKey:@"eid"];
            e.name = [match valueForKey:@"name"];
            e.location = [match valueForKey:@"location"];
            e.pic_big = [match valueForKey:@"picture"];
            e.latitude = [match valueForKey:@"latitude"];
            e.longitude = [match valueForKey:@"longitude"];
            e.dateStart = [match valueForKey:@"startDate"];
            e.dateEnd = [match valueForKey:@"endDate"];
            e.timeStart = [match valueForKey:@"startTime"];
            e.timeEnd = [match valueForKey:@"endTime"];
            
            [result addObject:e];
        }
    }
    
    return result;
}

+ (Store *)instance
{
    if (_store == nil) {
        
        _store = [[Store alloc] init];
    }
    
    return _store;
}

@end
