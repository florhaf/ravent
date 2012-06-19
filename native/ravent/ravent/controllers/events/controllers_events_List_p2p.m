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

- (void)reloadTableViewDataSourceWithIndex:(int)index
{    
    _data = nil;
    _groupedData = nil;
    _sortedKeys = nil;
    
    switch (index) {
            
        case 0:
            _data = _party;
            _groupedData = _groupedParty;
            _sortedKeys = _sortedKeysParty;
            break;
        case 1:
            _data = _chill;
            _groupedData = _groupedChill;
            _sortedKeys = _sortedKeysChill;
            break;
        case 2:
            _data = _art;
            _groupedData = _groupedArt;
            _sortedKeys = _sortedKeysArt;
            break;
        case 3:
            _data = _other;
            _groupedData = _groupedOther;
            _sortedKeys = _sortedKeysOther;
            break;
        default:
            break;
    }
    
    
    [self.tableView reloadData];
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
    
    //[super onLoadEvents:objects];
    
    [self onLoadData:objects withSuccess:^ {

        
        _party = [[NSMutableArray alloc] init];
        _chill = [[NSMutableArray alloc] init];
        _art = [[NSMutableArray alloc] init];
        _other = [[NSMutableArray alloc] init];
        
        _sortedKeysParty = [[NSMutableArray alloc] init];
        _sortedKeysChill = [[NSMutableArray alloc] init];
        _sortedKeysArt = [[NSMutableArray alloc] init];
        _sortedKeysOther = [[NSMutableArray alloc] init];
        
        _groupedParty = [[NSMutableDictionary alloc] init];
        _groupedChill = [[NSMutableDictionary alloc] init];
        _groupedArt = [[NSMutableDictionary alloc] init];
        _groupedOther = [[NSMutableDictionary alloc] init];
        
        
        for (models_Event *e in objects) {
            
            if (e.filter != nil && [e.filter rangeOfString:@"Party"].location != NSNotFound) {
                
                [_party addObject:e];
                
            }
            
            if (e.filter != nil &&[e.filter rangeOfString:@"Chill"].location != NSNotFound) {
                
                [_chill addObject:e];
                
            }
            
            if (e.filter != nil &&[e.filter rangeOfString:@"Entertain"].location != NSNotFound) {
                
                [_art addObject:e];
                
            }
            
            if (e.filter == nil || (([e.filter rangeOfString:@"Party"].location == NSNotFound) &&
                                    ([e.filter rangeOfString:@"Chill"].location == NSNotFound) &&
                                    ([e.filter rangeOfString:@"Entertain"].location == NSNotFound))) {
                
                [_other addObject:e];
                
            }
        }
        
        _groupedParty = [models_Event getGroupedData:_party];
        _groupedChill = [models_Event getGroupedData:_chill];
        _groupedArt = [models_Event getGroupedData:_art];
        _groupedOther = [models_Event getGroupedData:_other];
        
        _sortedKeysParty = [[_groupedParty allKeys] sortedArrayUsingSelector:@selector(compare:)];
        _sortedKeysChill = [[_groupedChill allKeys] sortedArrayUsingSelector:@selector(compare:)];
        _sortedKeysArt = [[_groupedArt allKeys] sortedArrayUsingSelector:@selector(compare:)];
        _sortedKeysOther = [[_groupedOther allKeys] sortedArrayUsingSelector:@selector(compare:)];
        

        [[NSNotificationCenter defaultCenter] postNotificationName:@"onLoadEventsP2P" object:self];
        
//        _data = _party;
//        _groupedData = _groupedParty;
//        _sortedKeys = _sortedKeysParty;
        
    }];

    [[controllers_events_Map_p2p instance] loadData:_data];
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
