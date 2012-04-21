//
//  UItableViewEvents.m
//  ravent
//
//  Created by florian haftman on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UItableViewEvents.h"

#import "controllers_events_Details.h"

@implementation UITableViewEvents

- (id)initWithUser:(models_User *)user
{
    self = [super init];
    
    if (self) {
        
        [[NSBundle mainBundle] loadNibNamed:@"views_events_item_Event" owner:self options:nil];
        
        _itemSize = CGSizeMake(_item.frame.size.width, _item.frame.size.height);
        _titleSize = CGSizeMake(_itemTitle.frame.size.width, _itemTitle.frame.size.height);
        _subTitleSize = CGSizeMake(_itemSubTitle.frame.size.width, _itemSubTitle.frame.size.height);
        
        _user = user;
        _event = [[models_Event alloc] initWithDelegate:self andSelector:@selector(onLoadEvents:)];
        
        [self loadDataWithUserLocation];
        
        
    }
    
    return self;
}

- (void)onLoadEvents:(NSArray *)objects
{
    [self onLoadData:objects withSuccess:^ {
        
        _data = objects;
        _groupedData = [models_Event getGroupedData:_data];
        _sortedKeys = [[_groupedData allKeys] sortedArrayUsingSelector:@selector(compare:)];
    }];
}

- (void)loadDataWithUserLocation
{
    _user.locationDelegate = self;
    _user.locationSuccess = @selector(onLocationSuccess);
    _user.locationFailure = @selector(onLocationFailure:);
    [_user getLocation];
}

- (void)onLocationSuccess
{
    [self loadData];
}

- (void)onLocationFailure:(NSError *)error
{
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    [objects addObject:error];
    
    [self onLoadEvents:objects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *key = [_sortedKeys objectAtIndex:section];
    models_Event *e = (models_Event *)[[_groupedData valueForKey:key]objectAtIndex:0];
    return e.groupTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat result = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    CGFloat actualHeight;
    
    NSString *section = [_sortedKeys objectAtIndex:indexPath.section];
    NSMutableArray *rows = [_groupedData objectForKey:section];
    models_Event *e = [rows objectAtIndex:indexPath.row];
    
    actualHeight = [e.name sizeWithFont:_itemTitle.font constrainedToSize:CGSizeMake(_titleSize.width, 2000) lineBreakMode:UILineBreakModeWordWrap].height;
    if (actualHeight > _titleSize.height) {
        
        result = result + (actualHeight - _titleSize.height);
    }
    
    actualHeight = [e.location sizeWithFont:_itemSubTitle.font constrainedToSize:CGSizeMake(_subTitleSize.width, 2000) lineBreakMode:UILineBreakModeWordWrap].height;
    if (actualHeight > _subTitleSize.height) {
        
        result = result + (actualHeight - _subTitleSize.height);
    }
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSString *section = [_sortedKeys objectAtIndex:indexPath.section];
    NSMutableArray *rows = [_groupedData objectForKey:section];
    models_Event *event = [rows objectAtIndex:indexPath.row];
    
    [[NSBundle mainBundle] loadNibNamed:@"views_events_item_Event" owner:self options:nil];
    
    _itemTitle.text = event.name;
    _itemSubTitle.text = event.location;
    _itemImage.imageURL = [NSURL URLWithString:event.picture];
    _itemTime.text = [NSString stringWithFormat:@"%@ - %@", event.timeStart, event.timeEnd];
    _itemDistance.text = [NSString stringWithFormat:@"%@ mi.", event.distance];
    
    [self resizeAndPositionCellItem];
    
    [cell.contentView addSubview:_item];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *section = [_sortedKeys objectAtIndex:indexPath.section];
    NSMutableArray *rows = [_groupedData objectForKey:section];
    
    models_Event *event = [rows objectAtIndex:indexPath.row];
    
    controllers_events_Details *details = [[controllers_events_Details alloc] initWithEvent:[event copy]]; 
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target:details action:@selector(cancellAllRequests)];
    UIViewController *rootController = self;
    
    while (![rootController.parentViewController isKindOfClass:[UINavigationController class]]) {
        
        rootController = rootController.parentViewController;
    }
    
    [rootController.navigationItem setBackBarButtonItem: backButton];
    [self.navigationController pushViewController:details animated:YES];
}

- (void)reloadTableViewDataSource
{
	_reloading = YES;
    [self loadDataWithUserLocation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [_event cancelAllRequests];
}

@end
