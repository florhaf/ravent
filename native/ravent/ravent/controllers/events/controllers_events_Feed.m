//
//  controllers_events_Feed.m
//  ravent
//
//  Created by florian haftman on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_events_Feed.h"
#import "models_User.h"
#import "JBAsyncImageView.h"
#import "MBProgressHUD.h"

@implementation controllers_events_Feed

- (id)initWithEvent:(models_Event *)event
{
    self = [super init];
    if (self) {
        
        [[NSBundle mainBundle] loadNibNamed:@"views_events_item_Comment" owner:self options:nil];
        
        _itemSize = CGSizeMake(_item.frame.size.width, _item.frame.size.height);
        _titleSize = CGSizeMake(_itemTitle.frame.size.width, _itemTitle.frame.size.height);
        _subTitleSize = CGSizeMake(_itemSubTitle.frame.size.width, _itemSubTitle.frame.size.height);
        
        _event = event;
        _comment = [[models_Comment alloc] initWithDelegate:self andSelector:@selector(onLoadFeed:)];
        
        [self loadData];
    }
    return self;
}

- (void)loadData
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
    [params setValue:_event.eid forKey:@"eid"];
    [params setValue:[models_User crtUser].timeZone forKey:@"timezone_offset"];
    
    [_comment loadFeedWithParams:params];
}

- (void)onLoadFeed:(NSArray *)objects
{
    [super onLoadData:objects withSuccess:^ {
        
        _data = [[NSMutableArray alloc] initWithArray:objects]; 
        
//        if (_data == nil || [_data count] == 0) {
//            
//            _showEmptyMessage = YES;
//            _emptyMessage = @"be the first to post";
//        }
    }];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat result = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    CGFloat actualHeight;
    
    models_Comment *c = [_data objectAtIndex:indexPath.row];
    NSString *name = [NSString stringWithFormat:@"%@ %@", c.firstName, c.lastName];
    
    actualHeight = [name sizeWithFont:_itemTitle.font constrainedToSize:CGSizeMake(_titleSize.width, 2000) lineBreakMode:UILineBreakModeWordWrap].height;
    if (actualHeight > _titleSize.height) {
        
        result = result + (actualHeight - _titleSize.height);
    }
    
    actualHeight = [c.message sizeWithFont:_itemSubTitle.font constrainedToSize:CGSizeMake(_subTitleSize.width, 2000) lineBreakMode:UILineBreakModeWordWrap].height;
    if (actualHeight > _subTitleSize.height) {
        
        result = result + (actualHeight - _subTitleSize.height);
    }
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    [[NSBundle mainBundle] loadNibNamed:@"views_events_item_Comment" owner:self options:nil];
    
    models_Comment *c = [_data objectAtIndex:indexPath.row];
    
    _itemTitle.text = [NSString stringWithFormat:@"%@ %@", c.firstName, c.lastName];
    _itemSubTitle.text = c.message;
    _itemImage.imageURL = [NSURL URLWithString:c.pictureUser];
    _itemImage.clipsToBounds = YES;
    _itemImage.contentMode = UIViewContentModeScaleAspectFill;
    _itemTime.text = c.time;
    
    [self resizeAndPositionCellItem];
    
    [cell.contentView addSubview:_item];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

@end
