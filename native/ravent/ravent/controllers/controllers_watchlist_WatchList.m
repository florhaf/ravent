//
//  controllers_watchlist_WatchListViewController.m
//  ravent
//
//  Created by florian haftman on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_watchlist_WatchList.h"
#import "ActionDispatcher.h"
#import "Store.h"

@implementation controllers_watchlist_WatchList

static controllers_watchlist_WatchList *_ctrl;

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataWithSpinner) name:@"addedToWatchList" object:nil];
        
        [self loadDataWithSpinner];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //_hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)loadDataWithUserLocation
{
    [super loadDataWithUserLocation];
}

- (void)updateLoadingMessageWith:(NSString *)text
{
    [super updateLoadingMessageWith:text];
}

- (void)loadData
{    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
    [params setValue:[models_User crtUser].latitude forKey:@"latitude"];
    [params setValue:[models_User crtUser].longitude forKey:@"longitude"];
    [params setValue:[models_User crtUser].timeZone forKey:@"timezone_offset"];                
    
    _url = [@"calendar" appendQueryParams:params];
    
    
    Action *upadteLoadingMessageAction = [[Action alloc] initWithDelegate:self andSelector:@selector(updateLoadingMessageWith:)];
    [[ActionDispatcher instance] add:upadteLoadingMessageAction named:_url];
    
    [_event reloadWithParams:params];
}

- (void)onLoadEvents:(NSArray *)objects
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    _hud = nil;
    
    if ([objects count] == 0) {
        
        [[NSBundle mainBundle] loadNibNamed:@"views_Empty_WL" owner:self options:nil];
    }
    
    [self onLoadData:objects withSuccess:^ {
        
        _data = objects;
        _groupedData = [models_Event getGroupedData:_data];
        _sortedKeys = [[_groupedData allKeys] sortedArrayUsingSelector:@selector(compare:)];
    }];
    
    if (_data != nil && [_data count] == 1) {
        
        //[self loadEventDetails:[_data objectAtIndex:0]];
    }
}

+ (controllers_watchlist_WatchList *)instance
{
    if (_ctrl == nil) {
        
        _ctrl = [[controllers_watchlist_WatchList alloc] initWithUser:[[models_User crtUser] copy]];
        _ctrl.view.frame = CGRectMake(0, 0, _ctrl.view.frame.size.width, _ctrl.view.frame.size.height);
    }
    
    return _ctrl;
}

+ (void)release
{
    [_ctrl cancelAllRequests];
    _ctrl = nil;
}

@end
