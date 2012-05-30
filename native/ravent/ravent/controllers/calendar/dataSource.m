//
//  dataSource.m
//  ravent
//
//  Created by florian haftman on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "dataSource.h"
#import "Store.h"
#import "JSON.h"

static BOOL IsDateBetweenInclusive(NSDate *date, NSDate *begin, NSDate *end)
{
    return [date compare:begin] != NSOrderedAscending && [date compare:end] != NSOrderedDescending;
}

@interface dataSource ()
- (NSArray *)eventsFrom:(NSDate *)fromDate to:(NSDate *)toDate;
- (NSArray *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate;
@end

@implementation dataSource

@synthesize dataReady;

+ (dataSource *)dataSource
{
    return [[[self class] alloc] init];
}

- (id)init
{
    if (self = [super init]) {
        
        items = [[NSMutableArray alloc] init];
        events = [[NSMutableArray alloc] init];
        buffer = [[NSMutableData alloc] init];        
    }
    return self;
}

- (models_Event *)eventAtIndexPath:(NSIndexPath *)indexPath
{
    return [items objectAtIndex:indexPath.row];
}

#pragma mark UITableViewDataSource protocol conformance

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _item.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *identifier = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    [[NSBundle mainBundle] loadNibNamed:@"views_events_item_Calendar" owner:self options:nil];
    
    models_Event *event = [self eventAtIndexPath:indexPath];

    _name.text = event.name;
    _location.text = event.location;
    _picture.imageURL = [NSURL URLWithString:event.picture];
    
    [cell.contentView addSubview:_item];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items count];
}

#pragma mark Fetch from the internet

- (void)fetchEventsFrom:(NSDate *)from To:(NSDate *)to
{
    Store *store = [Store instance];
    events = [[NSMutableArray alloc] init];
    NSDate *ptrDate = [from copy];
    
    while ([ptrDate compare:to] != NSOrderedDescending) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM d, yyyy"];
        NSString *strFromDate = [dateFormatter stringFromDate:ptrDate];
        
        [events addObjectsFromArray:[store findEventsForDate:strFromDate]];
        
        ptrDate = [ptrDate dateByAddingTimeInterval:86400];
    }
    
    dataReady = YES;
    [callback loadedDataSource:self];
}

#pragma mark KalDataSource protocol conformance

- (void)presentingDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate delegate:(id<KalDataSourceCallbacks>)delegate
{
    /* 
     * In this example, I load the entire dataset in one HTTP request, so the date range that is 
     * being presented is irrelevant. So all I need to do is make sure that the data is loaded
     * the first time and that I always issue the callback to complete the asynchronous request
     * (even in the trivial case where we are responding synchronously).
     */
    
//    if (dataReady) {
//        [callback loadedDataSource:self];
//        return;
//    }
    
    callback = delegate;
    [self fetchEventsFrom:fromDate To:toDate];
}

- (NSArray *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    if (!dataReady)
        return [NSArray array];
    
    NSArray *array = [self eventsFrom:fromDate to:toDate];
    
    
    return [array valueForKeyPath:@"dateStart"];
}

- (void)loadItemsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    if (!dataReady)
        return;
    
    [items addObjectsFromArray:[self eventsFrom:fromDate to:toDate]];
}

- (void)removeAllItems
{
    [items removeAllObjects];
}

#pragma mark -

- (NSArray *)eventsFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    NSMutableArray *matches = [NSMutableArray array];
    for (models_Event *event in events) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM d, yyyy"];
        NSDate *dateFromString = [dateFormatter dateFromString:event.dateStart];
     
        if (IsDateBetweenInclusive(dateFromString, fromDate, toDate)) {
            
            [matches addObject:event];   
        }
    }
    
    return matches;
}

@end
