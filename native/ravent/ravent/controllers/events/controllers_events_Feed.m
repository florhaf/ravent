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
#import "controllers_events_Pic_big.h"


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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataWithSpinner) name:@"reloadComments" object:nil];
        
        [self trackPageView:@"events_feed" forEvent:_event.eid];
    }
    return self;
}

- (void)loadData
{
    if (_data != nil) {
        
        for (models_Comment *c in _data) {
            
            c.cellHeight = _item.frame.size.height;
        }
    }
    
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
        
        
        for (models_Comment *c in _data) {
            
            if (c.picture != nil) {
                
                c.pic_small = [c.picture stringByReplacingOccurrencesOfString:@"_n.jpg" withString:@"_s.jpg"];
            }
            
            c.picUser_small = [c.pictureUser stringByReplacingOccurrencesOfString:@"_n.jpg" withString:@"_s.jpg"];
        }
        
    }];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSBundle mainBundle] loadNibNamed:@"views_events_item_Comment" owner:self options:nil];
    
    CGFloat result = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    CGFloat actualHeight;
    
    if (_data == nil) {
        
        return result;
    }
    
    models_Comment *c = [_data objectAtIndex:indexPath.row];
    NSString *name = [NSString stringWithFormat:@"%@ %@", c.firstName, c.lastName];
    
    actualHeight = [name sizeWithFont:_itemTitle.font constrainedToSize:CGSizeMake(_titleSize.width, 2000) lineBreakMode:UILineBreakModeWordWrap].height;
    if (actualHeight > _titleSize.height) {
        
        result = result + (actualHeight - _titleSize.height);
    }
    
    if (c.message != nil && ![c.message isEqualToString:@""]) {
        
        actualHeight = [c.message sizeWithFont:_itemSubTitle.font constrainedToSize:CGSizeMake(_subTitleSize.width, 2000) lineBreakMode:UILineBreakModeWordWrap].height;
        if (actualHeight > _subTitleSize.height) {
            
            result = result + (actualHeight - _subTitleSize.height);
        }   
    }

    if (c.picture != nil) {
        
        result = result + 283;
    }
    
    c.cellHeight = result;
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    models_Comment *c = [_data objectAtIndex:indexPath.row];
    
    if (c.picture != nil) {
    
        [[NSBundle mainBundle] loadNibNamed:@"views_events_item_CommentPic" owner:self options:nil];

        if ([_imagesCache.allKeys containsObject:c.picture]) {
            
            _commentImg.image = (UIImage *)[_imagesCache objectForKey:c.picture];
        } else {
            
            _commentImg.imageURL = [NSURL URLWithString:c.picture];
            _commentImg.delegate = self;
        }
        _commentImg.clipsToBounds = YES;
        _commentImg.contentMode = UIViewContentModeScaleAspectFill;
        
    } else {
        
        [[NSBundle mainBundle] loadNibNamed:@"views_events_item_Comment" owner:self options:nil];
    }
    
    _itemTitle.text = [NSString stringWithFormat:@"%@", c.firstName];
    _itemSubTitle.text = c.message;
    
    // image
    // ***********************************************
    if ([_imagesCache.allKeys containsObject:c.picUser_small]) {
        
        _itemImage.image = (UIImage *)[_imagesCache objectForKey:c.picUser_small];
    } else {
        
        _itemImage.imageURL = [NSURL URLWithString:c.picUser_small];
        _itemImage.delegate = self;
    }
    _itemImage.clipsToBounds = YES;
    _itemImage.contentMode = UIViewContentModeScaleAspectFill;
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZ"];
    NSDate *timeDate = [dateFormatter dateFromString:[c.time stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
    
    [dateFormatter setDateFormat:@"MMM d @ hh:mm:ss a"];
    NSString *timeStr = [dateFormatter stringFromDate:timeDate];
    
    _itemTime.text = timeStr;
    
    [self resizeAndPositionCellItem];
    
    [cell.contentView addSubview:_item];
    
    [_bg setFrame:CGRectMake(0, 0, 320, c.cellHeight)];
    
    return cell;
}

-(IBAction)onPictureTap:(id)sender
{
    UITableViewCell *cell = (UITableViewCell *)[sender superview];
    
    int i = 0;
    while (![[[cell subviews] objectAtIndex:i] isKindOfClass:[JBAsyncImageView class]]) {
        i++;
    }
    
    JBAsyncImageView *picture = (JBAsyncImageView *)[[cell subviews] objectAtIndex:i];
    
    _photos = [[NSMutableArray alloc] init];
    
    [_photos insertObject:[MWPhoto photoWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", picture.imageURL]]] atIndex:0];
    
    MWPhotoBrowser *picController = [[MWPhotoBrowser alloc] initWithDelegate:self];
    picController.wantsFullScreenLayout = YES;
    picController.displayActionButton = NO;
    [picController setInitialPageIndex:0];
    
    UINavigationController *picModal = [[UINavigationController alloc] initWithRootViewController:picController];
    
    [self.parentViewController presentModalViewController:picModal animated:YES];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadComments" object:nil];
    
    _comment = nil;
    
    _itemTime = nil;
    _commentImg = nil;
    _bg = nil;
    
    _photos = nil;
}

@end
