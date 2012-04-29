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
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)loadDataWithUserLocation
{
    [super loadDataWithUserLocation];
    
    [[controllers_events_Map_p2p instance] loading];
}

- (void)loadData
{    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
    [params setValue:[models_User crtUser].latitude forKey:@"latitude"];
    [params setValue:[models_User crtUser].longitude forKey:@"longitude"];
    [params setValue:[models_User crtUser].timeZone forKey:@"timezone_offset"];
    
    [_event loadEventsWithParams:params];
    
    [[controllers_events_Map_p2p instance] setMapLocation:YES];
}

- (void)onLoadEvents:(NSArray *)objects
{
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
