//
//  controllers_dropagem_List.m
//  ravent
//
//  Created by florian haftman on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_dropagem_List.h"
#import "ActionDispatcher.h"

@implementation controllers_dropagem_List

static controllers_dropagem_List *_ctrl;

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
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_isFromDetails) {
        
        _groupedData = nil;
        _data = nil;
        _sortedKeys = nil;
        
        [self.tableView reloadData];
        
        [self loadDataWithSpinner];
    } else {
     
        _isFromDetails = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    //_hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, 200, 44)];
    textLabel.textColor = [UIColor lightGrayColor];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.opaque = YES;
    [textLabel setFont:[UIFont boldSystemFontOfSize:17]];
    
    textLabel.text = @"Where are you at?";
    
    self.tableView.tableHeaderView = textLabel;
    
    
    
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
    [params setValue:[NSNumber numberWithDouble:0.1] forKey:@"radius"];
    [params setValue:[NSNumber numberWithInt:6] forKey:@"timeframe"];
    
    _url = [@"events" appendQueryParams:params];
    Action *upadteLoadingMessageAction = [[Action alloc] initWithDelegate:self andSelector:@selector(updateLoadingMessageWith:)];
    [[ActionDispatcher instance] add:upadteLoadingMessageAction named:_url];
    
    [_event loadEventsWithParams:params];
}

- (void)onLoadEvents:(NSArray *)objects
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    _hud = nil;
    
    if ([objects count] == 0) {
        
        [[NSBundle mainBundle] loadNibNamed:@"views_Empty_EventP2P" owner:self options:nil];
    }
    
    [self onLoadData:objects withSuccess:^ {
        
        _data = objects;
        _groupedData = [models_Event getGroupedData:_data];
        _sortedKeys = [[_groupedData allKeys] sortedArrayUsingSelector:@selector(compare:)];
    }];
}

- (void)loadEventDetails:(models_Event *)event
{
    [super loadEventDetails:event];
    
    _isFromDetails = YES;
}

+ (controllers_dropagem_List *)instance
{
    if (_ctrl == nil) {
        
        _ctrl = [[controllers_dropagem_List alloc] initWithUser:[[models_User crtUser] copy]];
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
