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

#import "controllers_events_Details_Map.h"
#import "postController.h"
#import "Store.h"
#import "ActionDispatcher.h"
#import "controllers_App.h"
#import "controllers_events_Pic_big.h"
#import <RestKit/RKErrorMessage.h>
#import <QuartzCore/QuartzCore.h>


@implementation controllers_events_Details

@synthesize photos = _photos;
@synthesize delegateBack = _delegateBack;
@synthesize selectorBack = _selectorBack;

- (id)initWithEvent:(models_Event *)event withBackDelegate:(id)delegate backSelector:(SEL)sel
{
    self = [super initWithEvent:event];
    
    if (self != nil) {
        
        _isNotReloadable = YES;
        _delegateBack = delegate;
        _selectorBack = sel;
        
        [[NSBundle mainBundle] loadNibNamed:@"views_events_Details" owner:self options:nil];
        
        Action *shareAction = [[Action alloc] initWithDelegate:self andSelector:@selector(share:)];
        [[ActionDispatcher instance] add:shareAction named:@"share"];
        
        _headerSize = CGSizeMake(_header.frame.size.width, _header.frame.size.height);
        _headerTitleSize = CGSizeMake(_headerNameLabel.frame.size.width, _headerNameLabel.frame.size.height);
        _headerSubTitleSize = CGSizeMake(_headerLocationLabel.frame.size.width, _headerLocationLabel.frame.size.height);
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        
        [params setValue:_event.eid forKey:@"eid"];
        [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
        
        _picturesLoader = [[models_Comment alloc] initWithDelegate:self andSelector:@selector(onPicturesLoad:)];
        [_picturesLoader loadPicturesWithParams:params];
        _photos = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)onPicturesLoad:(NSArray *)objects
{
    if (objects != nil) {
        
        for (models_Comment *pic in objects) {
        
            [_photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:pic.picture]]];
        }
    }
}

- (void)share:(NSArray *)friends
{
    if (_eventLoader == nil) {
        
        _eventLoader = [[models_Event alloc] init];
    }
    
    _eventLoader.callbackResponseFailure = @selector(shareFailure:);
    
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
    [YRDropdownView showDropdownInView:[controllers_App instance].view 
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
            
            [YRDropdownView showDropdownInView:[controllers_App instance].view 
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

- (IBAction)backButton_Tap:(id)sender
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_delegateBack performSelector:_selectorBack];
#pragma clang diagnostic pop
}

- (IBAction)addToListButton_Tap:(id)sender
{
    NSString *msg = [[Store instance]saveEvent:_event];
    
    if ([msg rangeOfString:@"added"].location != NSNotFound) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addedToWatchList" object:nil];   
    }
    
    [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                 title:@"Calendar" 
                                detail:msg
                                 image:[UIImage imageNamed:@"dropdown-alert"]
                              animated:YES];
}

- (IBAction)snap_Tap:(id)sender
{
    if (_event.rsvp_status == nil || [_event.rsvp_status isEqualToString:@""] || [_event.rsvp_status isEqualToString:@"not replied"]) {
        
        [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                     title:@"Warning" 
                                    detail:@"You must RSVP to post a picture"
                                     image:[UIImage imageNamed:@"dropdown-alert"]
                                  animated:YES];
        
        return;
    }
    
    postController *post = [[postController alloc] initWithNibName:@"views_Post" bundle:nil isForPicture:YES];
    post.isForEvent = YES;
    post.toId = _event.eid;
    
    UINavigationController *postModal = [[UINavigationController alloc] initWithRootViewController:post];
    
    [self presentModalViewController:postModal animated:YES];
}

- (IBAction)mapButton_Tap:(id)sender
{
    _isButtonTap = YES;
    
    controllers_events_Details_Map *mapController = [[controllers_events_Details_Map alloc] initWithEvent:[_event copy]];
    UINavigationController *feedModal = [[UINavigationController alloc] initWithRootViewController:mapController];
    
    [self presentModalViewController:feedModal animated:YES];
}

- (IBAction)picButton_Tap:(id)sender
{
    _isButtonTap = YES;
    
    [_photos insertObject:[MWPhoto photoWithURL:[NSURL URLWithString:_event.pic_big]] atIndex:0];
    
    MWPhotoBrowser *picController = [[MWPhotoBrowser alloc] initWithDelegate:self];
    picController.wantsFullScreenLayout = YES;
    picController.displayActionButton = NO;
    [picController setInitialPageIndex:0];
    
    
    UINavigationController *picModal = [[UINavigationController alloc] initWithRootViewController:picController];
    [self presentModalViewController:picModal animated:YES];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count)
        return [self.photos objectAtIndex:index];
    return nil;
}

- (void)newRating:(int)rating
{
    [_voteLoading setHidden:NO];
    [_voteLoading.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [_voteLoading.layer setBorderWidth:1];
    _voteLoading.layer.cornerRadius = 3;
    _voteLoading.layer.masksToBounds = YES;
    //_voteLoading.frame = _voteView.frame;
    [_header bringSubviewToFront:_voteLoading];
    //[_header sendSubviewToBack:_voteView];
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
    
    [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                 title:@"Success" 
                                detail:@"Vote submitted"
                                 image:[UIImage imageNamed:@"dropdown-alert"]
                              animated:YES];
}

- (void)onVoteFailure:(NSMutableDictionary *)response
{
    [_voteLoading setHidden:YES];
    
    NSString *errorMsg = (NSString *)[response valueForKey:@"statusCode"];
    
    [YRDropdownView showDropdownInView:[controllers_App instance].view
                                 title:@"Error" 
                                detail:errorMsg
                                 image:[UIImage imageNamed:@"dropdown-alert"]
                              animated:YES];
}

- (IBAction)rsvp:(id)sender
{
    NSString *rsvpValue = @"yes";
    _event.rsvp_status = @"attending";
    
    if (_segment.selectedSegmentIndex == 1) {
        
        rsvpValue = @"maybe";
        _event.rsvp_status = @"maybe attending";
    } else {
        
        if (_segment.selectedSegmentIndex == 2) {
            
            rsvpValue = @"no";
            _event.rsvp_status = @"not attending";
        }
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:rsvpValue forKey:@"rsvp"];
    [params setValue:_event.eid forKey:@"eventID"];
    [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
    
    
    _event.delegate = self;
    [_event rsvp:params success:@selector(onRsvpSuccess:) failure:@selector(onRsvpFailure:) sender:_rsvp];
}

- (void)onRsvpSuccess:(NSString *)response
{
    [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                 title:@"Success" 
                                detail:@"RSVP submitted"
                                 image:[UIImage imageNamed:@"dropdown-alert"]
                              animated:YES];
    
}

- (void)onRsvpFailure:(NSMutableDictionary *)response
{
    [_segment setSelected:NO];
    
    _event.rsvp_status = @"";
    
    NSString *errorMsg = (NSString *)[response valueForKey:@"statusCode"];
    
    [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                 title:@"Error" 
                                detail:errorMsg
                                 image:[UIImage imageNamed:@"dropdown-alert"]
                              animated:YES];
}

#pragma mark - View lifecycle

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0) {
        
        _mapImage.frame = CGRectMake(0, scrollView.contentOffset.y, _mapImage.frame.size.width, _mapImageHeight - scrollView.contentOffset.y);
        
        _backButton.frame = CGRectMake(_backButton.frame.origin.x, scrollView.contentOffset.y + 6, _backButton.frame.size.width, _backButton.frame.size.height);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // override to avoid getting the pull to refresh
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _refreshHeaderView.delegate = nil;
    [_refreshHeaderView removeFromSuperview];
       
    [[NSBundle mainBundle] loadNibNamed:@"views_events_Details" owner:self options:nil];
        
    // HEADER
    _headerDateLabel.text = [NSString stringWithFormat:@"%@ to %@", _event.dateStart, _event.dateEnd];
    _headerNameLabel.text = _event.name;
    _headerLocationLabel.text = _event.location;
    _headerImage.imageURL = [NSURL URLWithString:_event.pic_big];
    _headerImage.clipsToBounds = YES;
    _headerImage.contentMode = UIViewContentModeScaleAspectFill;
    _headerTimeLabel.text = [NSString stringWithFormat:@"%@ - %@", _event.timeStart, _event.timeEnd];
    _headerDistanceLabel.text = [NSString stringWithFormat:@"%@ mi.", _event.distance];
    
    // SCORE
    for (int i = 0; i < [_event.score intValue]; i++) {
        
        UIImageView *image = (UIImageView *)[_headerScore.subviews objectAtIndex:i];
        image.image = [UIImage imageNamed:@"diamond"];
    }
    
    // VOTE
    _voteView = [[DLStarRatingControl alloc] initWithFrame:_headerVoteLabel.frame andStars: 5];
    [_voteView setRating:1];
    [_voteView setAlpha:0.8];
    _voteView.delegate = self;
    [_header addSubview:_voteView];
    [_headerVoteLabel removeFromSuperview];
    
    // RSVP
    NSArray *objects = [NSArray arrayWithObjects:@"Yes", @"Maybe", @"No", nil];
    _segment = [[STSegmentedControl alloc] initWithItems:objects];
	_segment.frame = CGRectMake(20, 637, 280, 40);
	_segment.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[_header addSubview:_segment];
    
    // MAP
    if (_event.latitude != nil && ![_event.latitude isEqualToString:@""]) {
        
        NSString *mapUrl = @"http://maps.googleapis.com/maps/api/staticmap";
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:[NSString stringWithFormat:@"%@,%@", _event.latitude, _event.longitude] forKey:@"center"];
        [params setValue:@"14" forKey:@"zoom"];
        [params setValue:@"320x360" forKey:@"size"];
        [params setValue:@"roadmap" forKey:@"maptype"];
        [params setValue:@"2" forKey:@"scale"];
        [params setValue:[NSString stringWithFormat:@"size:mid|%@,%@", _event.latitude, _event.longitude] forKey:@"markers"];
        [params setValue:@"true" forKey:@"sensor"];
        mapUrl = [mapUrl appendQueryParams:params];
        _mapImage.imageURL = [NSURL URLWithString:mapUrl];
    } else {
        
        _mapImage.image = [UIImage imageNamed:@"noMap"];
    }
    
    _mapImage.clipsToBounds = YES;
    _mapImage.contentMode = UIViewContentModeScaleAspectFill;
    _mapImageHeight = _mapImage.frame.size.height;
    
    [_headerNameLabel sizeToFit];
    
    // STATS
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:_event.eid forKey:@"eid"];
    [params setValue:_event.eid forKey:@"eventID"];
    [params setValue:[models_User crtUser].uid forKey:@"userID"];
    [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
    
    if (_eventLoader == nil) {
        
        _eventLoader = [[models_Event alloc] init];
    }
    
    // does not load if same instance ? 
    [_event loadStatsWithParams:params andTarget:self andSelector:@selector(onEventStatsLoad:)];
    [_eventLoader loadRsvpWithParams:params andTarget:self andSelector:@selector(onRsvpLoad:)];
    
    self.tableView.tableHeaderView = _header;
    self.tableView.scrollsToTop = YES;
    
    _tickerItems = [[NSArray alloc] initWithObjects:_event.name, nil];
    [_ticker reloadData];
}

- (void)onEventStatsLoad:(NSArray *)objects
{
    if (objects != nil && [objects count] > 0) {
        
        if ([[objects objectAtIndex:0] isKindOfClass:[RKErrorMessage class]]) {
            
            RKErrorMessage *error = (RKErrorMessage *)[objects objectAtIndex:0];
            
            [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                         title:@"Error stats" 
                                        detail:error.errorMessage
                                         image:[UIImage imageNamed:@"dropdown-alert"]
                                      animated:YES];
            
        } else {
        
            models_Event *e = [objects objectAtIndex:0];
        
        
            double d = [e.female_ratio doubleValue];
            d = d * 100;
        
            _labelFemaleRatio.text = [NSString stringWithFormat:@"%.0f%%", d + 1];
            _labelMaleRatio.text = [NSString stringWithFormat:@"%.0f%%", 100 - (d + 1)];
            _labelTotalAttendings.text = e.nb_attending;
        }
    }
}

- (void)onRsvpLoad:(NSArray *)objects
{
    [_segment setSelected:NO];
    
    if (objects != nil && [objects count] > 0) {
        
        
        if ([[objects objectAtIndex:0] isKindOfClass:[RKErrorMessage class]]) {
            
            RKErrorMessage *error = (RKErrorMessage *)[objects objectAtIndex:0];
            
            [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                         title:@"Error RSVP" 
                                        detail:error.errorMessage
                                         image:[UIImage imageNamed:@"dropdown-alert"]
                                      animated:YES];
            
        } else {
         
            models_Event *e = [objects objectAtIndex:0];
            
            _event.rsvp_status = e.rsvp_status;
            
            if ([e.rsvp_status isEqualToString:@"attending"]) {
                
                [_segment setSelectedSegmentIndex:0];
                
            } else if ([e.rsvp_status isEqualToString:@"maybe attending"]) {
                
                [_segment setSelectedSegmentIndex:1];
                
            } else if ([e.rsvp_status isEqualToString:@"not attending"]) {
            
                [_segment setSelectedSegmentIndex:2];
            }
        }
    }
    
    [_segment addTarget:self action:@selector(rsvp:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!_isButtonTap) {
        
        [self cancelAllRequests];   
    }
    
    _isButtonTap = NO;
}


- (UIColor*) backgroundColorForTickerView:(MKTickerView *)vertMenu
{
    return [UIColor clearColor];
}

- (int) numberOfItemsForTickerView:(MKTickerView *)tabView
{
    return [_tickerItems count];
}

- (NSString*) tickerView:(MKTickerView *)tickerView titleForItemAtIndex:(NSUInteger)index
{
    return [_tickerItems objectAtIndex:index];
}

- (NSString*) tickerView:(MKTickerView *)tickerView valueForItemAtIndex:(NSUInteger)index
{
    return nil;
}

- (UIImage*) tickerView:(MKTickerView*) tickerView imageForItemAtIndex:(NSUInteger) index
{
    return nil;
}

@end
