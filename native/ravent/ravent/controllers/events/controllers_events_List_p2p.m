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

@synthesize party = _party;
@synthesize chill = _chill;
@synthesize art = _art;
@synthesize other = _other;
@synthesize sort = _sort;

static controllers_events_List_p2p *_ctrl;

- (id)initWithUser:(models_User *)user
{
    self = [super initWithUser:user];
    
    if (self != nil) {
        
        [self trackPageView:@"events_p2p" forEvent:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(0, 0, 320, 416);
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

- (void)reloadTableViewDataSourceWithNoFadeWithIndex:(int)index
{    
    _data = nil;
    _groupedData = nil;
    _sortedKeys = nil;
    
    switch (index) {
            
        case 0:
            if (_party != nil && [_party count] > 0) {
                
                _data = _party;
                _groupedData = _groupedParty;
                _sortedKeys = _sortedKeysParty;
            }
            break;
        case 1:
            if (_chill != nil && [_chill count] > 0) {
                
                _data = _chill;
                _groupedData = _groupedChill;
                _sortedKeys = _sortedKeysChill;
            }
            break;
        case 2:
            if (_art != nil && [_art count] > 0) {
                
                _data = _art;
                _groupedData = _groupedArt;
                _sortedKeys = _sortedKeysArt;
            }
            break;
        case 3:
            if (_other != nil && [_other count] > 0) {
                
                _data = _other;
                _groupedData = _groupedOther;
                _sortedKeys = _sortedKeysOther;
            }
            break;
        default:
            break;
    }
    
    switch (_sort) {
            
        case byScore:
            [self sortByScore];
            break;
        case byDistance:
            [self sortByDistance];
            break;
        case byTime:
            [self sortByTime];
            break;
        default:
            break;
    }
    
    [self.tableView reloadData];
}

- (void)reloadTableViewDataSourceWithIndex:(int)index
{   
    BOOL bFade = (_data != nil);
    
    // load data to display
    _data = nil;
    _groupedData = nil;
    _sortedKeys = nil;
    
    switch (index) {
            
        case 0:
            if (_party != nil && [_party count] > 0) {
             
                _data = _party;
                _groupedData = _groupedParty;
                _sortedKeys = _sortedKeysParty;
            }
            break;
        case 1:
            if (_chill != nil && [_chill count] > 0) {
                
                _data = _chill;
                _groupedData = _groupedChill;
                _sortedKeys = _sortedKeysChill;
            }
            break;
        case 2:
            if (_art != nil && [_art count] > 0) {
                
                _data = _art;
                _groupedData = _groupedArt;
                _sortedKeys = _sortedKeysArt;
            }
            break;
        case 3:
            if (_other != nil && [_other count] > 0) {
                
                _data = _other;
                _groupedData = _groupedOther;
                _sortedKeys = _sortedKeysOther;
            }
            break;
        default:
            break;
    }
    
    // sort data
    switch (_sort) {
            
        case byScore:
            [self sortByScore];
            break;
        case byDistance:
            [self sortByDistance];
            break;
        case byTime:
            [self sortByTime];
            break;
        default:
            break;
    }
    
    if (bFade) {
     
        // transition animation
        [UIView animateWithDuration:0.15 animations:^{
            
            [self.tableView setAlpha:0];
        } completion:^(BOOL finished) {
            
            
            [self.tableView reloadData];
            
            [self.tableView setContentOffset:CGPointZero animated:NO];
            [UIView animateWithDuration:0.15 animations:^(){
                
                [self.tableView setAlpha:1];    
            }];
        }];
    } else {
        
        [self.tableView setAlpha:0];
        [self.tableView reloadData];
        
        [self.tableView setContentOffset:CGPointZero animated:NO];
        [UIView animateWithDuration:0.15 animations:^(){
            
            [self.tableView setAlpha:1];    
        }];
    }
}

- (NSArray *)bubbleUpFeatured:(NSArray *)original
{
    NSMutableArray *featured = [[NSMutableArray alloc] init];
    NSMutableArray *nonFeatured = [[NSMutableArray alloc] init];
    
    for (models_Event *e in original) {
        
        if (e.featured != nil && ![e.featured isEqualToString:@""]) {
            
            [featured addObject:e];
        } else {
            
            [nonFeatured addObject:e];
        }
    }
    
    return [featured arrayByAddingObjectsFromArray:nonFeatured];
}

- (void)sortByScore
{
    NSMutableDictionary *sortedDic = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in _sortedKeys) {
        
        NSArray *ar = [_groupedData objectForKey:key];
            
        NSArray *sortedAr = [ar sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            
            models_Event *e1 = (models_Event *)a;
            models_Event *e2 = (models_Event *)b;
            
            NSInteger score1 = [e1.score intValue];
            NSInteger score2 = [e2.score intValue];
            
            if (score1 == score2) {
                
                return NSOrderedSame;
            } else if (score1 > score2) {
                
                return NSOrderedAscending;
            } else {
                
                return NSOrderedDescending;
            }
        }];
        
        [sortedDic setObject:[self bubbleUpFeatured:sortedAr] forKey:key];
    }
    
    _groupedData = sortedDic;
}

- (void)sortByDistance
{
    NSMutableDictionary *sortedDic = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in _sortedKeys) {
        
        NSArray *ar = [_groupedData objectForKey:key];
        
        NSArray *sortedAr = [ar sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            
            models_Event *e1 = (models_Event *)a;
            models_Event *e2 = (models_Event *)b;
            
            NSInteger d1 = [e1.distance intValue];
            NSInteger d2 = [e2.distance intValue];
            
            if (d1 == d2) {
                
                return NSOrderedSame;
            } else if (d1 > d2) {
                
                return NSOrderedDescending;
            } else {
                
                return NSOrderedAscending;
            }
        }];
        
        [sortedDic setObject:[self bubbleUpFeatured:sortedAr] forKey:key];
    }
    
    _groupedData = sortedDic;
}

- (void)sortByTime
{
    NSMutableDictionary *sortedDic = [[NSMutableDictionary alloc] init];
    
    
    
    for (NSString *key in _sortedKeys) {
        
        NSArray *ar = [_groupedData objectForKey:key];
        
        NSArray *sortedAr = [ar sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            
            models_Event *e1 = (models_Event *)a;
            models_Event *e2 = (models_Event *)b;
            
            NSDateFormatter *dateFormat1 = [[NSDateFormatter alloc] init];
            [dateFormat1 setDateFormat:@"LLL d, yyyy h:mm a"];
            NSString *sDateTime1 = [NSString stringWithFormat:@"%@ %@", e1.dateStart, e1.timeStart];
            NSDate *d1 = [dateFormat1 dateFromString:sDateTime1];
            
            NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
            [dateFormat2 setDateFormat:@"LLL d, yyyy h:mm a"];
            NSString *sDateTime2 = [NSString stringWithFormat:@"%@ %@", e2.dateStart, e2.timeStart];
            NSDate *d2 = [dateFormat2 dateFromString:sDateTime2];
            
            return [d1 compare:d2];
        }];
        
        [sortedDic setObject:[self bubbleUpFeatured:sortedAr] forKey:key];
    }
    
    _groupedData = sortedDic;
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

+ (BOOL)isIntanciated
{
    return (_ctrl != nil);
}

+ (void)deleteInstance
{
    [_ctrl cancelAllRequests];
    _ctrl = nil;
}

@end
