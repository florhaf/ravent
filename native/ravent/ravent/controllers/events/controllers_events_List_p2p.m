//
//  controllers_events_List_p2p.m
//  ravent
//
//  Created by florian haftman on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_events_List_p2p.h"
#import "ActionDispatcher.h"
#import "MBProgressHUD.h"

@implementation controllers_events_List_p2p

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)loadData
{
    [[ActionDispatcher instance] execute:@"controller_events_List_p2p_Loading"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
    [params setValue:[models_User crtUser].latitude forKey:@"latitude"];
    [params setValue:[models_User crtUser].longitude forKey:@"longitude"];
    [params setValue:[models_User crtUser].timeZone forKey:@"timezone_offset"];
    
    [_event loadEventsWithParams:params];
}

- (void)onLoadEvents:(NSArray *)objects
{
    [super onLoadEvents:objects];
    
    [[ActionDispatcher instance] execute:@"controller_events_List_p2p_LoadData" with:objects];
}

@end
