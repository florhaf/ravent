//
//  Store.h
//  ravent
//
//  Created by florian haftman on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Store : NSObject<NSFetchedResultsControllerDelegate> {
    
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (NSFetchedResultsController *)fetchedResultsController;
- (NSString *)saveEid:(NSString *)eid forDate:(NSString *)startDate;
- (NSMutableArray *)findEidsForDate:(NSString *)startDate;

+ (Store *)instance;

@end
