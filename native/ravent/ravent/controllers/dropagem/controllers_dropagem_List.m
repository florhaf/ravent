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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 44)];
    textLabel.textColor = [UIColor grayColor];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.opaque = YES;
    textLabel.shadowColor = [UIColor blackColor];
    textLabel.shadowOffset = CGSizeMake(0, 1);
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
    [params setValue:[NSNumber numberWithDouble:1] forKey:@"radius"];
    [params setValue:[NSNumber numberWithInt:6] forKey:@"timeframe"];
    
    _url = [@"events" appendQueryParams:params];
    Action *upadteLoadingMessageAction = [[Action alloc] initWithDelegate:self andSelector:@selector(updateLoadingMessageWith:)];
    [[ActionDispatcher instance] add:upadteLoadingMessageAction named:_url];
    
    [_event loadEventsWithParams:params];
}

- (void)onLoadEvents:(NSArray *)objects
{
    if ([objects count] == 0) {
        
        [[NSBundle mainBundle] loadNibNamed:@"views_Empty_EventP2P" owner:self options:nil];
    }
    
    [self onLoadData:objects withSuccess:^ {
        
        _data = objects;
        _groupedData = [models_Event getGroupedData:_data];
        _sortedKeys = [[_groupedData allKeys] sortedArrayUsingSelector:@selector(compare:)];
    }];
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
