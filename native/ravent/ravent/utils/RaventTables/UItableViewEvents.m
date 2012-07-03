//
//  UItableViewEvents.m
//  ravent
//
//  Created by florian haftman on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UItableViewEvents.h"
#import "QuartzCore/CALayer.h"
#import "controllers_events_DetailsContainer.h"

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
        
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        self.tableView.tableFooterView = [[UIView alloc] init];
    }
    
    return self;
}

- (void)onLoadEvents:(NSArray *)objects
{
    [self onLoadData:objects withSuccess:^ {
        
        if (objects != nil) {
            
            _data = objects;
            _groupedData = [models_Event getGroupedData:_data];
            _sortedKeys = [[_groupedData allKeys] sortedArrayUsingSelector:@selector(compare:)];
        }
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

- (models_Event *)getEventForSection:(NSInteger)section andRow:(NSInteger)row
{
    return (models_Event *)[self getObjForSection:section andRow:row];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    models_Event *e = [self getEventForSection:section andRow:0];
    
    if (e != nil && e.groupTitle != nil && ![e.groupTitle isEqualToString:@""]) {
        
        return [e.groupTitle uppercaseString];
    } else {
        
        return @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat result = [super tableView:tableView heightForRowAtIndexPath:indexPath];
//    CGFloat actualHeight;
//    
//    NSString *section = [_sortedKeys objectAtIndex:indexPath.section];
//    NSMutableArray *rows = [_groupedData objectForKey:section];
//    models_Event *e = [rows objectAtIndex:indexPath.row];
//    
//    actualHeight = [e.name sizeWithFont:_itemTitle.font constrainedToSize:CGSizeMake(_titleSize.width, 2000) lineBreakMode:UILineBreakModeWordWrap].height;
//    if (actualHeight > _titleSize.height) {
//        
//        result = result + (actualHeight - _titleSize.height);
//    }
//    
//    actualHeight = [e.location sizeWithFont:_itemSubTitle.font constrainedToSize:CGSizeMake(_subTitleSize.width, 2000) lineBreakMode:UILineBreakModeWordWrap].height;
//    if (actualHeight > _subTitleSize.height) {
//        
//        result = result + (actualHeight - _subTitleSize.height);
//    }
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    models_Event *event = [self getEventForSection:indexPath.section andRow:indexPath.row];
    
    if (event != nil) {
    
        [[NSBundle mainBundle] loadNibNamed:@"views_events_item_Event" owner:self options:nil];

        
        // image
        if ([_imagesCache.allKeys containsObject:event.pic_big]) {
            
            _itemImage.image = (UIImage *)[_imagesCache objectForKey:event.pic_big];
        } else {
            
            _itemImage.imageURL = [NSURL URLWithString:event.pic_big];
            _itemImage.delegate = self;
        }
        _itemImage.clipsToBounds = YES;
        _itemImage.contentMode = UIViewContentModeScaleAspectFill;
        
        _itemTitle.text = event.name;
        _itemSubTitle.text = event.location;
        _itemTime.text = [[NSString stringWithFormat:@"%@ - %@", event.timeStart, event.timeEnd] lowercaseString];
        _itemDistance.text = [NSString stringWithFormat:@"%@ mi.", event.distance];
        _itemVenueCategory.text = event.venue_category;
        
        
        if (indexPath.row == 0) {
            
            [_special setHidden:NO];
        }
        
        for (int i = 0; i < [event.score intValue]; i++) {
        
            UIImageView *image = (UIImageView *)[_itemScore.subviews objectAtIndex:i];
            image.image = [UIImage imageNamed:@"diamond"];
            image.alpha = 0.8;
        }
    
        //_itemTitle.font = [_itemTitle.font fontWithSize:[self getFontSizeForLabel:_itemTitle]];
    
        [cell.contentView addSubview:_item];
    }
    
    return cell;
}

- (CGFloat)resizeAndPositionCellItem
{
    CGFloat delta = [super resizeAndPositionCellItem] + 21;
    
    //_bg.frame = CGRectMake(_item.frame.origin.x, _item.frame.origin.y, _item.frame.size.width, _item.frame.size.height);
    
    return delta;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    models_Event *event = [self getEventForSection:indexPath.section andRow:indexPath.row];
    
    if (event != nil) {
     
        [self loadEventDetails:event];
    }
}

- (void)loadEventDetails:(models_Event *)event
{
    _details = [[controllers_events_DetailsContainer alloc] initWithEvent:[event copy] withBackDelegate:self backSelector:@selector(onBackTap)]; 

    [self.navigationController pushViewController:_details animated:YES];    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
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
    
    
    [self performSelector:@selector(fadeToolbar) withObject:nil afterDelay:0.3];
}

- (void)fadeToolbar
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [self.navigationController.navigationBar setAlpha:0.5];
    [UIView commitAnimations];
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
    
    _imagesCache = nil;
}

@end
