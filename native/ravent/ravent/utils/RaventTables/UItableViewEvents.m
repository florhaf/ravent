//
//  UItableViewEvents.m
//  ravent
//
//  Created by florian haftman on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UItableViewEvents.h"
#import "QuartzCore/CALayer.h"
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
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSString *section = [_sortedKeys objectAtIndex:indexPath.section];
    NSMutableArray *rows = [_groupedData objectForKey:section];
    models_Event *event = [rows objectAtIndex:indexPath.row];
    
    [[NSBundle mainBundle] loadNibNamed:@"views_events_item_Event" owner:self options:nil];
    
    _itemTitle.text = event.name;
    _itemSubTitle.text = event.location;
    _itemImage.imageURL = [NSURL URLWithString:event.picture];
    _itemTime.text = [NSString stringWithFormat:@"%@ - %@", event.timeStart, event.timeEnd];
    _itemDistance.text = [NSString stringWithFormat:@"%@ mi.", event.distance];
        
    for (int i = 0; i < [event.score intValue]; i++) {
        
        UIImageView *image = (UIImageView *)[_itemScore.subviews objectAtIndex:i];
        image.image = [UIImage imageNamed:@"like"];
    }
    
    [self resizeAndPositionCellItem];
    
    [cell.contentView addSubview:_item];
    
    return cell;
}

- (CGFloat)resizeAndPositionCellItem
{
    CGFloat delta = [super resizeAndPositionCellItem];
    
    _bgLeft.frame = CGRectMake(_bgLeft.frame.origin.x, _bgLeft.frame.origin.y, _bgLeft.frame.size.width, _item.frame.size.height);
    
    _bgRight.frame = CGRectMake(_bgRight.frame.origin.x, _bgRight.frame.origin.y, _bgRight.frame.size.width, _item.frame.size.height);
    
    return delta;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *section = [_sortedKeys objectAtIndex:indexPath.section];
    NSMutableArray *rows = [_groupedData objectForKey:section];
    
    models_Event *event = [rows objectAtIndex:indexPath.row];
    
    [self loadEventDetails:event];
}

- (void)loadEventDetails:(models_Event *)event
{
    _details = [[controllers_events_Details alloc] initWithEvent:[event copy]]; 
    
    UIImage *backi = [UIImage imageNamed:@"backButton"];
    
    UIButton *backb = [UIButton buttonWithType:UIButtonTypeCustom];
    [backb addTarget:self action:@selector(onBackTap) forControlEvents:UIControlEventTouchUpInside];
    [backb setImage:backi forState:UIControlStateNormal];
    [backb setFrame:CGRectMake(0, 0, backi.size.width, backi.size.height)];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backb];

    UIViewController *rootController = self;
    
    while (![rootController.parentViewController isKindOfClass:[UINavigationController class]]) {
        
        rootController = rootController.parentViewController;
    }
    
    [rootController.navigationItem hidesBackButton];
    [_details.navigationItem setLeftBarButtonItem:backButton];
    [self.navigationController pushViewController:_details animated:YES];
    
}

- (void)onBackTap
{
    [(controllers_events_Details *)_details cancelAllRequests];
    [self.navigationController popViewControllerAnimated:YES];
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
