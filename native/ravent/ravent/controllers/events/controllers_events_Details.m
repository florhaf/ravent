//
//  controllers_events_Details.m
//  ravent
//
//  Created by florian haftman on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_events_Details.h"
#import "YRDropdownView.h"
#import "JBAsyncImageView.h"
#import "MBProgressHUD.h"
#import "controllers_friends_share.h"
#import "controllers_events_Description.h"
#import "controllers_events_FeedContainer.h"
#import "controllers_events_Details_Map.h"
#import "Store.h"
#import "ActionDispatcher.h"

@implementation controllers_events_Details

- (id)initWithEvent:(models_Event *)event
{
    self = [super initWithEvent:event];
    
    if (self != nil) {
        
        [[NSBundle mainBundle] loadNibNamed:@"views_events_Details" owner:self options:nil];
        
        Action *shareAction = [[Action alloc] initWithDelegate:self andSelector:@selector(share:)];
        [[ActionDispatcher instance] add:shareAction named:@"share"];
        
        _headerSize = CGSizeMake(_header.frame.size.width, _header.frame.size.height);
        _headerTitleSize = CGSizeMake(_headerNameLabel.frame.size.width, _headerNameLabel.frame.size.height);
        _headerSubTitleSize = CGSizeMake(_headerLocationLabel.frame.size.width, _headerLocationLabel.frame.size.height);
    }
    
    return self;
}

- (void)share:(NSArray *)friends
{
    if (_eventLoader == nil) {
        
        _eventLoader = [[models_Event alloc] init];
        _eventLoader.callbackResponseFailure = @selector(shareFailure:);
    }
    
    _friendsSharedTo = [friends copy];
    NSMutableDictionary *params = nil;
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:_data];
    
    for (int i = 0; i < [friends count]; i++) {
        
        params = [[NSMutableDictionary alloc] init];
        [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
        [params setValue:[models_User crtUser].uid forKey:@"userID"];
        [params setValue:_event.eid forKey:@"eventID"];
        [params setValue:((models_User *)[friends objectAtIndex:i]).uid forKey:@"friendID"];
        
        [array addObject:[friends objectAtIndex:i]];
        
        [_eventLoader share:params];
    }

    [self onLoadInvited:array];
}

- (void)shareFailure:(NSMutableDictionary *)error
{
    [YRDropdownView showDropdownInView:self.view 
                                 title:@"Error sharing" 
                                detail:[error valueForKey:@"statusCode"]
                                 image:[UIImage imageNamed:@"dropdown-alert"]
                              animated:YES];
    
    for (int i = 0; i < [_friendsSharedTo count]; i++) {
        
        models_User *friend = [_friendsSharedTo objectAtIndex:i];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid like %@", friend.uid];
        NSArray *result = [_data filteredArrayUsingPredicate:predicate];
        
        if (result != nil && [result count] > 0) {
            
            [_data delete:[result objectAtIndex:0]];
        }
    }
    
    [self onLoadInvited:_data];
}

- (id)initWithReloadEvent:(models_Event *)event
{
    self = [super initWithEvent:event];
    
    if (self != nil) {
        
        _eventLoader = [[models_Event alloc] init];
        _eventLoader.delegate = self;
        _eventLoader.callback = @selector(onLoadEvents:);
        
        [[NSBundle mainBundle] loadNibNamed:@"views_events_Details" owner:self options:nil];
        
        _headerSize = CGSizeMake(_header.frame.size.width, _header.frame.size.height);
        _headerTitleSize = CGSizeMake(_headerNameLabel.frame.size.width, _headerNameLabel.frame.size.height);
        _headerSubTitleSize = CGSizeMake(_headerLocationLabel.frame.size.width, _headerLocationLabel.frame.size.height);
    }
    
    _user.locationDelegate = self;
    _user.locationSuccess = @selector(onLocationSuccess);
    _user.locationFailure = @selector(onLocationFailure:);
    
    [_user getLocation];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    return self;
}

- (void)onLocationSuccess
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
    [params setValue:[models_User crtUser].latitude forKey:@"latitude"];
    [params setValue:[models_User crtUser].longitude forKey:@"longitude"];
    [params setValue:[models_User crtUser].timeZone forKey:@"timezone_offset"];
    [params setValue:_event.eid forKey:@"eventID"];
    
    [_eventLoader reloadWithParams:params];
}

- (void)onLocationFailure:(NSError *)error
{
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    [objects addObject:error];
    
    [self onLoadEvents:objects];
}

- (void)onLoadEvents:(NSArray *)objects
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if ([objects count] > 0) {
        
        id object = [objects objectAtIndex:0];
        
        if ([object isKindOfClass:[NSError class]]) {
            
            NSError *error = (NSError *)object;
            
            [YRDropdownView showDropdownInView:self.view 
                                         title:@"Error" 
                                        detail:[error localizedDescription]
                                         image:[UIImage imageNamed:@"dropdown-alert"]
                                      animated:YES];
        } else {
            
            _event = [objects objectAtIndex:0];
            
            [self viewDidLoad];
        }
    } else {
        
        [[NSBundle mainBundle] loadNibNamed:@"views_Empty" owner:self options:nil];
        self.tableView.tableFooterView = _emptyView;
    }
}

#pragma mark - Button event handler

- (IBAction)addToListButton_Tap:(id)sender
{
    NSString *msg = [[Store instance]saveEvent:_event];
    
    [YRDropdownView showDropdownInView:self.view 
                                 title:@"Calendar" 
                                detail:msg
                                 image:[UIImage imageNamed:@"dropdown-alert"]
                              animated:YES];
}

- (IBAction)shareButton_Tap:(id)sender
{
    controllers_friends_share *shareController = [[controllers_friends_share alloc] initWithUser:[_user copy] invited:_data];
    UINavigationController *shareModal = [[UINavigationController alloc] initWithRootViewController:shareController];
    
    [self presentModalViewController:shareModal animated:YES];
}

- (IBAction)descriptionButton_Tap:(id)sender
{
    controllers_events_Description *descController = [[controllers_events_Description alloc] initWithNibName:@"views_events_Description" bundle:[NSBundle mainBundle] event:[_event copy]];
    UINavigationController *descModal = [[UINavigationController alloc] initWithRootViewController:descController];
    
    [self presentModalViewController:descModal animated:YES];
}

- (IBAction)feedButton_Tap:(id)sender
{
    controllers_events_FeedContainer *feedController = [[controllers_events_FeedContainer alloc] initWithEvent:[_event copy]];
    
    UINavigationController *feedModal = [[UINavigationController alloc] initWithRootViewController:feedController];
    
    [self presentModalViewController:feedModal animated:YES];
}

- (IBAction)mapButton_Tap:(id)sender
{
    controllers_events_Details_Map *mapController = [[controllers_events_Details_Map alloc] initWithEvent:[_event copy]];
    UINavigationController *feedModal = [[UINavigationController alloc] initWithRootViewController:mapController];
    
    [self presentModalViewController:feedModal animated:YES];
}

- (void)newRating:(int)rating
{
    [_voteLoading setHidden:NO];
    _voteLoading.frame = _voteView.frame;
    [_header bringSubviewToFront:_voteLoading];
    [_header sendSubviewToBack:_voteView];
    [((UIActivityIndicatorView *)[_voteLoading.subviews objectAtIndex:0]) startAnimating];
        
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:[NSNumber numberWithInt:rating] forKey:@"vote"];
    [params setValue:_user.uid forKey:@"userID"];
    [params setValue:_event.eid forKey:@"eventID"];
    [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
    
    _event.delegate = self;
    [_event vote:params success:@selector(onVoteSuccess:) failure:@selector(onVoteFailure:) sender:_voteView];
}

- (void)onVoteSuccess:(NSString *)response
{
    [_voteLoading setHidden:YES];
    [_header bringSubviewToFront:_voteView];
    
    [YRDropdownView showDropdownInView:self.view 
                                 title:@"Success" 
                                detail:@"Vote submitted"
                                 image:[UIImage imageNamed:@"dropdown-alert"]
                              animated:YES];
}

- (void)onVoteFailure:(NSMutableDictionary *)response
{
    [_voteLoading setHidden:YES];
    
    NSString *errorMsg = (NSString *)[response valueForKey:@"statusCode"];
        
    [YRDropdownView showDropdownInView:self.view 
                                 title:@"Error" 
                                detail:errorMsg
                                 image:[UIImage imageNamed:@"dropdown-alert"]
                              animated:YES];
}

- (IBAction)rsvp:(id)sender
{
    NSString *rsvpValue = @"yes";
    
    if (_rsvp.selectedSegmentIndex == 1) {
        
        rsvpValue = @"maybe";
    } else {
        
        if (_rsvp.selectedSegmentIndex == 2) {
            
            rsvpValue = @"no";
        }
    }
    
    [_voteLoading setHidden:NO];
    _voteLoading.frame = _rsvp.frame;
    [_header bringSubviewToFront:_voteLoading];
    [_header sendSubviewToBack:_rsvp];
    [((UIActivityIndicatorView *)[_voteLoading.subviews objectAtIndex:0]) startAnimating];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:rsvpValue forKey:@"rsvp"];
    [params setValue:_user.uid forKey:@"userID"];
    [params setValue:_event.eid forKey:@"eventID"];
    [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
    
    _event.delegate = self;
    [_event rsvp:params success:@selector(onRsvpSuccess:) failure:@selector(onRsvpFailure:) sender:_rsvp];
}

- (void)onRsvpSuccess:(NSString *)response
{
    [_voteLoading setHidden:YES];
    
    [YRDropdownView showDropdownInView:self.view 
                                 title:@"Success" 
                                detail:@"RSVP submitted"
                                 image:[UIImage imageNamed:@"dropdown-alert"]
                              animated:YES];
}

- (void)onRsvpFailure:(NSMutableDictionary *)response
{
    [_voteLoading setHidden:YES];
    
    [_rsvp setSelected:NO];
    
    NSString *errorMsg = (NSString *)[response valueForKey:@"statusCode"];
    
    [YRDropdownView showDropdownInView:self.view 
                                 title:@"Error" 
                                detail:errorMsg
                                 image:[UIImage imageNamed:@"dropdown-alert"]
                              animated:YES];
}

#pragma mark - View lifecycle



- (void)viewDidLoad
{
    [super viewDidLoad];
       
    [[NSBundle mainBundle] loadNibNamed:@"views_events_Details" owner:self options:nil];
        
    _headerGroupLabel.text = [NSString stringWithFormat:@"%@", _event.groupTitle];
    _headerDateLabel.text = [NSString stringWithFormat:@"(%@ to %@)", _event.dateStart, _event.dateEnd];
    _headerNameLabel.text = _event.name;
    _headerLocationLabel.text = _event.location;
    _headerImage.imageURL = [NSURL URLWithString:_event.pic_big];
    _headerTimeLabel.text = [NSString stringWithFormat:@"%@ - %@", _event.timeStart, _event.timeEnd];
    _headerDistanceLabel.text = [NSString stringWithFormat:@"%@ mi.", _event.distance];
    
    for (int i = 0; i < [_event.score intValue]; i++) {
        
        UIImageView *image = (UIImageView *)[_headerScore.subviews objectAtIndex:i];
        image.image = [UIImage imageNamed:@"diamond"];
    }
    
    _voteView = [[DLStarRatingControl alloc] initWithFrame:_headerVoteLabel.frame andStars: 5];
    _voteView.delegate = self;
    [_header addSubview:_voteView];
    [_headerVoteLabel removeFromSuperview];
    
    
    NSString *mapUrl = @"http://maps.googleapis.com/maps/api/staticmap";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:[NSString stringWithFormat:@"%@,%@", _event.latitude, _event.longitude] forKey:@"center"];
    [params setValue:@"16" forKey:@"zoom"];
    [params setValue:@"320x160" forKey:@"size"];
    [params setValue:@"roadmap" forKey:@"maptype"];
    [params setValue:@"2" forKey:@"scale"];
    [params setValue:[NSString stringWithFormat:@"%@,%@", _event.latitude, _event.longitude] forKey:@"markers"];
    [params setValue:@"true" forKey:@"sensor"];

    mapUrl = [mapUrl appendQueryParams:params];
    _mapImage.imageURL = [NSURL URLWithString:mapUrl];

    _headerNameLabel.font = [_headerNameLabel.font fontWithSize:[self getFontSizeForLabel:_headerNameLabel]];
    
    [_headerGroupLabel sizeToFit];
    _headerDateLabel.frame = CGRectMake(_headerGroupLabel.frame.origin.x + _headerGroupLabel.frame.size.width + 4, _headerDateLabel.frame.origin.y, _headerDateLabel.frame.size.width, _headerDateLabel.frame.size.height);
    
    self.tableView.tableHeaderView = _header;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self cancelAllRequests];
}

@end
