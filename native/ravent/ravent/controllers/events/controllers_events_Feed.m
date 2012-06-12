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
#import "ActionDispatcher.h"

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
    
    _url = [@"comments" appendQueryParams:params];
    Action *upadteLoadingMessageAction = [[Action alloc] initWithDelegate:self andSelector:@selector(updateLoadingMessageWith:)];
    [[ActionDispatcher instance] add:upadteLoadingMessageAction named:_url];
    
    [_comment loadFeedWithParams:params];
}

- (void)onLoadFeed:(NSArray *)objects
{
    if (objects == nil || [objects count] == 0) {
        
        [[NSBundle mainBundle] loadNibNamed:@"views_Empty_Generic" owner:self options:nil];
        ((UILabel *)[_emptyMessageView.subviews objectAtIndex:0]).text = @"be the first to post";
    }
    
    [super onLoadData:objects withSuccess:^ {
        
        _data = [[NSMutableArray alloc] initWithArray:objects]; 
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
    
    
    if (c.pictureContent != nil) {
        
        JBAsyncImageView *imageView = [[JBAsyncImageView alloc] initWithFrame:CGRectMake(_itemTitle.frame.origin.x, _itemTitle.frame.origin.y + 21, 0, 0)];
        imageView.imageURL = [NSURL URLWithString:c.pictureContent];
        imageView.delegate = self;
        
        [self.view addSubview:imageView];
    }
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZ"];
    NSDate *timeDate = [dateFormatter dateFromString:[c.time stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
    
    [dateFormatter setDateFormat:@"MMM d @ hh:mm:ss a"];
    NSString *timeStr = [dateFormatter stringFromDate:timeDate];
    
    _itemTime.text = timeStr;
    
    [self resizeAndPositionCellItem];
    
    [cell.contentView addSubview:_item];
    
    return cell;
}

-(void)imageView:(JBAsyncImageView *)sender loadedImage:(UIImage *)imageLoaded fromURL:(NSURL *)url
{
    [sender setFrame:CGRectMake(sender.frame.origin.x, sender.frame.origin.y, imageLoaded.size.width * 0.5, imageLoaded.size.width * 0.5)];
    
    UIView *sub = [sender.superview.subviews objectAtIndex:1];
    
    sub.frame = CGRectMake(sub.frame.origin.x, sub.frame.origin.y + sender.frame.size.height, sub.frame.size.width, sub.frame.size.height);
    
    sub = [sender.superview.subviews objectAtIndex:2];
    
    sub.frame = CGRectMake(sub.frame.origin.x, sub.frame.origin.y + sender.frame.size.height, sub.frame.size.width, sub.frame.size.height);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

@end
