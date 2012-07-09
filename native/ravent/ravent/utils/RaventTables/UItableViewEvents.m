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
#import "NSString+Distance.h"

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
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    models_Event *event = [self getEventForSection:indexPath.section andRow:indexPath.row];
    
    if (event != nil) {
    
        [[NSBundle mainBundle] loadNibNamed:@"views_events_item_Event" owner:self options:nil];

        
        // image
        // ***********************************************
        if ([_imagesCache.allKeys containsObject:event.pic_big]) {
            
            _itemImage.image = (UIImage *)[_imagesCache objectForKey:event.pic_big];
        } else {
            
            _itemImage.imageURL = [NSURL URLWithString:event.pic_big];
            _itemImage.delegate = self;
        }
        _itemImage.clipsToBounds = YES;
        _itemImage.contentMode = UIViewContentModeScaleAspectFill;
        
        
        // date time
        // ***********************************************
        NSString * startDateWOYear = @"?";
        NSString * endDateWOYear = @"?";
        if (event.dateStart != nil && ![event.dateStart isEqualToString:@""]) {
            startDateWOYear = [event.dateStart substringToIndex:[event.dateStart rangeOfString:@","].location];
        }
        if (event.dateStart != nil && ![event.dateEnd isEqualToString:@""]) {
            endDateWOYear = [event.dateEnd substringToIndex:[event.dateEnd rangeOfString:@","].location];
        }
        
        // text
        // ***********************************************
        _itemTitle.text = event.name;
        _itemSubTitle.text = event.location;
        _itemStartTime.text = [[NSString stringWithFormat:@"%@ @ %@", startDateWOYear, event.timeStart] lowercaseString];
        _itemEndTime.text = [[NSString stringWithFormat:@"%@ @ %@", endDateWOYear, event.timeEnd] lowercaseString];
        _itemDistance.text = [NSString stringWithFormat:@"%@", [event.distance stringWithDistance]];
        _itemVenueCategory.text = event.venue_category;
        
        
        // special and features
        // ***********************************************
        if (event.featured != nil && ![event.featured isEqualToString:@""]) {
            [_featured setHidden:NO];
        }
        if (event.offerTitle != nil && ![event.offerTitle isEqualToString:@""]) {
            [_special setHidden:NO];
        }
        if (event.ticket_link != nil && ![event.ticket_link isEqualToString:@""]) {
            if (_special.hidden) {
                _ticket_link.frame = CGRectMake(_ticket_link.frame.origin.x + 20, _ticket_link.frame.origin.y, _ticket_link.frame.size.width, _ticket_link.frame.size.height);
            }
            [_ticket_link setHidden:NO];
        }
        
        
        // score
        // ***********************************************
        for (int i = 0; i < [event.score intValue]; i++) {
        
            UIImageView *image = (UIImageView *)[_itemScore.subviews objectAtIndex:i];
            image.image = [UIImage imageNamed:@"diamond"];
            image.alpha = 0.8;
        }
    
        [cell.contentView addSubview:_item];
        
        event = nil;
        startDateWOYear = nil;
        endDateWOYear = nil;
    }
    
    return cell;
}

- (CGFloat)resizeAndPositionCellItem
{
    CGFloat delta = [super resizeAndPositionCellItem] + 21;
    
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
    
    
    //[self performSelector:@selector(fadeToolbar) withObject:nil afterDelay:0.3];
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

- (void)dealloc
{
    _itemScore = nil;
    _itemStartTime = nil;
    _itemEndTime = nil;
    _itemDistance = nil;
    _itemVenueCategory = nil;
    
    _bg = nil;
    _special = nil;
    
    _featured = nil;
    _ticket_link = nil;
    
    _details = nil;
}

@end
