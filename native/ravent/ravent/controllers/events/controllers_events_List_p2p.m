//
//  controllers_events_List_p2p.m
//  ravent
//
//  Created by florian haftman on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_events_List_p2p.h"
#import "controllers_events_Map_p2p.h"
#import "ActionDispatcher.h"
#import "MBProgressHUD.h"

@implementation controllers_events_List_p2p

static controllers_events_List_p2p *_ctrl;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)loadDataWithUserLocation
{
    [super loadDataWithUserLocation];
    
    [[controllers_events_Map_p2p instance] loading];
}

- (void)updateLoadingMessageWith:(NSString *)text
{
    [super updateLoadingMessageWith:text];
    
    [[controllers_events_Map_p2p instance] updateLoadingMessageWith:text];
}

- (void)loadData
{    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
    [params setValue:[models_User crtUser].latitude forKey:@"latitude"];
    [params setValue:[models_User crtUser].longitude forKey:@"longitude"];
    [params setValue:[models_User crtUser].timeZone forKey:@"timezone_offset"];                
    [params setValue:[NSNumber numberWithInt:[models_User crtUser].searchRadius] forKey:@"radius"];
    [params setValue:[NSNumber numberWithInt:[models_User crtUser].searchWindow] forKey:@"timeframe"];
    
    
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
    
    [super onLoadEvents:objects];

    [[controllers_events_Map_p2p instance] loadData:objects];
}

+ (controllers_events_List_p2p *)instance
{
    if (_ctrl == nil) {
        
        _ctrl = [[controllers_events_List_p2p alloc] initWithUser:[[models_User crtUser] copy]];
        _ctrl.view.frame = CGRectMake(0, 0, _ctrl.view.frame.size.width, _ctrl.view.frame.size.height);
    }
    
    return _ctrl;
}

@end
