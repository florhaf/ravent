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
#import "UIImage+ImageWithUIView.h"
#import "controllers_events_Details_Map.h"
#import "postController.h"
#import "Store.h"
#import "ActionDispatcher.h"
#import "controllers_App.h"
#import "controllers_events_Pic_big.h"
#import <RestKit/RKErrorMessage.h>
#import <QuartzCore/QuartzCore.h>
#import "controllers_events_Tickets.h"
#import "controllers_events_Specials.h"
#import "NSString+Distance.h"
#import "Store.h"


@implementation controllers_events_Details

@synthesize photos = _photos;
@synthesize delegateBack = _delegateBack;
@synthesize selectorBack = _selectorBack;
@synthesize coordinate = _coordinate;

@synthesize dragViews = dragViews_;
@synthesize goodFrames =goodFrames_;
@synthesize badFrames = badFrames_;
@synthesize canDragMultipleViewsAtOnce =canDragMultipleViewsAtOnce_;
@synthesize canUseTheSameFrameManyTimes =canUseTheSameFrameManyTimes_;

static int _retryCounter;

- (id)initWithEvent:(models_Event *)event withBackDelegate:(id)delegate backSelector:(SEL)sel
{
    self = [super initWithEvent:event];
    
    if (self != nil) {
        
        _retryCounter = 0;
        _isNotReloadable = YES;
        _delegateBack = delegate;
        _selectorBack = sel;
        
        self.title = @"Gemster";
        
        
        
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
        
        
        _event.isGemDropped = [[Store instance] isGemDropped:_event.eid];
    }
    
    return self;
}

- (void)share:(NSArray *)friends
{
    if (_eventLoader == nil) {
        
        _eventLoader = [[models_Event alloc] init];
    }
    
    _eventLoader.callbackResponseFailure = @selector(shareFailure:);

    NSMutableDictionary *params = nil;    
    NSMutableArray *newData = [[NSMutableArray alloc] initWithArray:_data];
    
    [newData addObjectsFromArray:friends];
    _data = nil;
    _data = [[NSArray alloc] initWithArray:newData];
    
    for (int i = 0; i < [friends count]; i++) {
            
            params = [[NSMutableDictionary alloc] init];
            [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
            [params setValue:[models_User crtUser].uid forKey:@"userID"];
            [params setValue:_event.eid forKey:@"eventID"];
            [params setValue:((models_User *)[friends objectAtIndex:i]).uid forKey:@"friendID"];
            
            [_eventLoader share:params];
    }
    
    [self.tableView reloadData];
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
        
        // nothing anymore
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
    _event.isInWatchList = YES;
    
    NSString *msg = [[Store instance]saveEvent:_event];
    
    if ([msg rangeOfString:@"added"].location != NSNotFound) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addedToWatchList" object:nil];   
    }
    
    [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                 title:@"Watchlist" 
                                detail:msg
                                 image:[UIImage imageNamed:@"dropdown-alert"]
                              animated:YES];
}

- (IBAction)snap_Tap:(id)sender
{
    _isButtonTap = YES;
    
    if (_event.rsvp_status == nil || [_event.rsvp_status isEqualToString:@""] || [_event.rsvp_status isEqualToString:@"not replied"]) {
        
        [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                     title:@"Warning" 
                                    detail:@"Per Facebook policy, you must RSVP yes or maybe to post a picture...\n"
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
    
    MWPhotoBrowser *picController = [[MWPhotoBrowser alloc] initWithDelegate:self];
    picController.wantsFullScreenLayout = YES;
    picController.displayActionButton = NO;
    [picController setInitialPageIndex:0];
    
    
    UINavigationController *picModal = [[UINavigationController alloc] initWithRootViewController:picController];
    [self presentModalViewController:picModal animated:YES];
}

#pragma mark - Album delegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count)
        return [self.photos objectAtIndex:index];
    return nil;
}


#pragma mark - vote and rsvp delegate

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
    [_actVote stopAnimating];
    // store eid in voted events
    _event.isGemDropped = YES;
    [[Store instance] saveEvent:_event];
    
    NSString *msg = @"You just dropped a Gem!";
    
    if (_event.offerTitle != nil && ![_event.offerTitle isEqualToString:@""]) {

        msg = [msg stringByAppendingString:@"\n\nGoodies unlocked"];
    }
    
    [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                 title:@"Congrats" 
                                detail:msg
                                 image:[UIImage imageNamed:@"dropdown-alert"]
                              animated:YES];
}

- (void)onVoteFailure:(NSMutableDictionary *)response
{
    [_actVote stopAnimating];
    
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
    
    if (_segment.selectedSegmentIndex == 0) {  
    
        [[Store instance]saveEvent:_event];
        
    } else if (_segment.selectedSegmentIndex == 1) {
        
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

        //NSLog(@"%f", scrollView.contentOffset.y);
    //[im setFrame:CGRectMake(0, 10, im.frame.size.width, im.frame.size.height)];
      
        //im.text = [NSString stringWithFormat:@"YO"];
        
        //[_map setHidden:NO];
        
        [_mapImage setFrame:CGRectMake(0, -80 + scrollView.contentOffset.y / 2, _mapImage.frame.size.width, _mapImage.frame.size.height)];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (!_isMapImageSet) {
        
        _isMapImageSet = YES;
        _mapImage.layer.contents = (id)[UIImage imageWithUIView:_map].CGImage;
        [_map removeFromSuperview];
        _map = nil;
    }
}

- (void)loadDropAGem
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"diamond.png" ofType:nil];
    
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    int framesY = (_detailsVersion == twogoodies) ? 435 : 450;
    
    
    self.goodFrames = [NSMutableArray arrayWithCapacity:1];
    self.badFrames = [NSMutableArray arrayWithCapacity:0];
    
    NSMutableArray *goodFrames = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *badFrames = [NSMutableArray arrayWithCapacity:0];
    self.dragViews = [NSMutableArray arrayWithCapacity:1];

    CGRect endFrame =   CGRectMake(226, framesY, 60, 50);
        
    [goodFrames addObject:TKCGRectValue(endFrame)];
        
    UIView *endView = [[UIView alloc] initWithFrame:endFrame];
    endView.layer.borderColor = [UIColor greenColor].CGColor;
    endView.layer.borderWidth = 1.0f;
        
    [self.view addSubview:endView];
        
    [self.goodFrames addObject:endView];
        
    self.canUseTheSameFrameManyTimes = NO;
    self.canDragMultipleViewsAtOnce = NO;
    
    
    CGRect startFrame = CGRectMake(30, framesY, 60, 50);
        
        
    TKDragView *dragView = [[TKDragView alloc] initWithImage:image
                                                      startFrame:startFrame
                                                      goodFrames:goodFrames
                                                       badFrames:badFrames
                                                     andDelegate:self];
        
        
        dragView.canDragMultipleDragViewsAtOnce = NO;
        dragView.canUseSameEndFrameManyTimes = YES;
        
        [self.dragViews addObject:dragView];
        
        [self.view addSubview:dragView];
        
        UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taped:)];
        [g setNumberOfTapsRequired:2];
        [dragView addGestureRecognizer:g];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _map.delegate = self;
    _refreshHeaderView.delegate = nil;
    [_refreshHeaderView removeFromSuperview];
       
    CGFloat segY = 0;
    

    if ((_event.ticket_link == nil || [_event.ticket_link isEqualToString:@""]) &&
        (_event.offerTitle == nil || [_event.offerTitle isEqualToString:@""])) {
        
        _detailsVersion = nogoodies;
        [[NSBundle mainBundle] loadNibNamed:@"views_events_Details" owner:self options:nil];
        segY = 568;
        
    } else if ((_event.ticket_link != nil && ![_event.ticket_link isEqualToString:@""]) &&
               (_event.offerTitle != nil && ![_event.offerTitle isEqualToString:@""])) {
        
        _detailsVersion = twogoodies;
        [[NSBundle mainBundle] loadNibNamed:@"views_events_Details2" owner:self options:nil];
        segY = 695;
    } else {
        
        _detailsVersion = onegoodies;
        [[NSBundle mainBundle] loadNibNamed:@"views_events_Details1" owner:self options:nil];
        segY = 665;
    }
    
    // HEADER
    _headerDateLabel.text = [NSString stringWithFormat:@"%@ to %@", _event.dateStart, _event.dateEnd];
    _headerNameLabel.text = _event.name;
    _headerLocationLabel.text = (_event.location != nil && ![_event.location isEqualToString:@""]) ? _event.location : @"N/A";
    _headerImage.imageURL = [NSURL URLWithString:_event.pic_big];
    _headerImage.clipsToBounds = YES;
    _headerImage.contentMode = UIViewContentModeScaleAspectFill;
    _headerTimeLabel.text = [NSString stringWithFormat:@"%@ - %@", _event.timeStart, _event.timeEnd];
    _headerDistanceLabel.text = [NSString stringWithFormat:@"%@", [_event.distance stringWithDistance]];
    _venueCategory.text = (![_event.venue_category isEqualToString:@""] && _event.venue_category != nil) ? _event.venue_category : @"venue category: N/A";
    [_photos insertObject:[MWPhoto photoWithURL:[NSURL URLWithString:_event.pic_big]] atIndex:0];
    [_headerNameLabel sizeToFit];
    
    // SCORE
    for (int i = 0; i < [_event.score intValue]; i++) {
        
        UIImageView *image = (UIImageView *)[_headerScore.subviews objectAtIndex:i];
        image.image = [UIImage imageNamed:@"diamond"];
    }
    
    // RSVP
    NSArray *objects = [NSArray arrayWithObjects:@"Yes", @"Maybe", @"No", nil];
    _segment = [[STSegmentedControl alloc] initWithItems:objects];
	_segment.frame = CGRectMake(20, segY, 280, 40);
	_segment.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[_header addSubview:_segment];
    
    // MAP
    _mapImageHeight = _map.frame.size.height;
    _map.scrollEnabled = NO;
    _map.zoomEnabled = NO;
    if (_event.latitude != nil && ![_event.latitude isEqualToString:@""]) {
        
        CLLocationCoordinate2D coord;
        coord.latitude = [_event.latitude doubleValue];
        coord.longitude = [_event.longitude doubleValue];
        _event.coordinate = coord;
        [_map addAnnotation:_event];
        
        _zoomLocation.latitude = [_event.latitude floatValue];
        _zoomLocation.longitude= [_event.longitude floatValue];
        _viewRegion = MKCoordinateRegionMakeWithDistance(_zoomLocation, 0.3*METERS_PER_MILE, 0.3*METERS_PER_MILE);
        MKCoordinateRegion adjustedRegion = [_map regionThatFits:_viewRegion];                
        [_map setRegion:adjustedRegion animated:YES];
        
    } else {
        
        //_mapImage.image = [UIImage imageNamed:@"noMap"];
    }
    
    UIImageView *ivtop = [[UIImageView alloc] initWithFrame:CGRectMake(0, _headerDateLabel.frame.origin.y - 10, 320, 20)];
    [ivtop setImage:[UIImage imageNamed:@"shadowBottom"]];
    [_header insertSubview:ivtop aboveSubview:_mapImage];
    
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
    
    // goodies
    if (_event.featured != nil && ![_event.featured isEqualToString:@""]) {
        [_featuredIcon setHidden:NO];
    }
    if (_detailsVersion == onegoodies) {
        if (_event.offerTitle != nil && ![_event.offerTitle isEqualToString:@""]) {
            _goodiesIcon.image = [UIImage imageNamed:@"goodiesGift"];
            _specialLabel.text = _event.offerTitle;
        } else {
            _goodiesIcon.image = [UIImage imageNamed:@"goodiesTicket"];
            _specialLabel.text = @"tickets available";
        }
    } else {
        _specialLabel.text = _event.offerTitle;
    }
    
    [self loadDropAGem];
}

- (IBAction)onTicket_Tap:(id)sender
{
    //_details = [[controllers_friends_Details alloc] initWithUser:[user copy]];
    
    controllers_events_Tickets *ticket = [[controllers_events_Tickets alloc] initWithURL:_event.ticket_link];
    
    UIImage *backi = [UIImage imageNamed:@"backButton"];
    
    UIButton *backb = [UIButton buttonWithType:UIButtonTypeCustom];
    [backb addTarget:self action:@selector(onBackTap) forControlEvents:UIControlEventTouchUpInside];
    [backb setImage:backi forState:UIControlStateNormal];
    [backb setFrame:CGRectMake(0, 0, backi.size.width, backi.size.height)];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backb];
    
    UIViewController *rootController = self;
    
    while (![rootController.parentViewController isKindOfClass:[UINavigationController class]]) {
        
        rootController = rootController.parentViewController;
    }
    
    [rootController.navigationItem hidesBackButton];
    [ticket.navigationItem setLeftBarButtonItem:backButton];
    [self.navigationController pushViewController:ticket animated:YES];
    
    [self performSelector:@selector(fadeInToolbar) withObject:nil afterDelay:0.3];

}

- (IBAction)onSpecials_Tap:(id)sender
{
    //controllers_events_Tickets *ticket = [[controllers_events_Tickets alloc] initWithURL:_event.ticket_link];
    
    controllers_events_Specials *spe = [[controllers_events_Specials alloc] initWithEvent:[_event copy]];
    
    UIImage *backi = [UIImage imageNamed:@"backButton"];
    
    UIButton *backb = [UIButton buttonWithType:UIButtonTypeCustom];
    [backb addTarget:self action:@selector(onBackTap) forControlEvents:UIControlEventTouchUpInside];
    [backb setImage:backi forState:UIControlStateNormal];
    [backb setFrame:CGRectMake(0, 0, backi.size.width, backi.size.height)];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backb];
    
    UIViewController *rootController = self;
    
    while (![rootController.parentViewController isKindOfClass:[UINavigationController class]]) {
        
        rootController = rootController.parentViewController;
    }
    
    [rootController.navigationItem hidesBackButton];
    [spe.navigationItem setLeftBarButtonItem:backButton];
    [self.navigationController pushViewController:spe animated:YES];
    
    [self performSelector:@selector(fadeInToolbar) withObject:nil afterDelay:0.3];
}

- (IBAction)onGoodies_Tap:(id)sender
{
    if (_event.ticket_link != nil && ![_event.ticket_link isEqualToString:@""]) {
        
        [self onTicket_Tap:sender];
    } else {
        
        [self onSpecials_Tap:sender];
    }
}

- (void)onEventStatsLoad:(NSArray *)objects
{
    [_actRatio1 stopAnimating];
    [_actRatio2 stopAnimating];
    [_actRatio3 stopAnimating];

    
    [_actRatio1 removeFromSuperview];
    [_actRatio2 removeFromSuperview];
    [_actRatio3 removeFromSuperview];
    
    _actRatio1 = nil;
    _actRatio2 = nil;
    _actRatio3 = nil;
    
    [_labelFemaleRatio setHidden:NO];
    [_labelMaleRatio setHidden:NO];
    [_labelTotalAttendings setHidden:NO];
    
    if (objects != nil && [objects count] > 0) {
        
        if ([[objects objectAtIndex:0] isKindOfClass:[NSError class]]) {
            
            NSError *error = (NSError *)[objects objectAtIndex:0];
            
            [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                         title:@"Error loading stats" 
                                        detail:error.localizedDescription
                                         image:[UIImage imageNamed:@"dropdown-alert"]
                                      animated:YES];
            
        } else {
        
            models_Event *e = [objects objectAtIndex:0];
        
        
            double d = [e.female_ratio doubleValue];
            d = d * 100;
        
            _labelFemaleRatio.text = [NSString stringWithFormat:@"%.0f%%", (d + 1 <= 100) ? d + 1 : 100 ];
            _labelMaleRatio.text = [NSString stringWithFormat:@"%.0f%%", (100 - (d + 1) >= 0) ? 100 - (d + 1) : 0];
            _labelTotalAttendings.text = e.nb_attending;
        }
    }
}

- (void)onRsvpLoad:(NSArray *)objects
{
    [_segment setSelected:NO];
    
    if (objects != nil && [objects count] > 0) {
        
        
        if ([[objects objectAtIndex:0] isKindOfClass:[NSError class]]) {
            
            NSError *error = (NSError *)[objects objectAtIndex:0];
            
            [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                         title:@"Error loading RSVP status" 
                                        detail:error.localizedDescription
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

- (void)onPicturesLoad:(NSArray *)objects
{
    if (objects != nil) {
        
        if ([objects count] > 0) {
            
            id obj = [objects objectAtIndex:0];
            
            if ([obj isKindOfClass:[NSError class]]) {
                
                NSError *error = (NSError *)obj;
                
                [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                             title:@"Error loading pictures" 
                                            detail:error.localizedDescription
                                             image:[UIImage imageNamed:@"dropdown-alert"]
                                          animated:YES];
            } else {
                
                for (models_Comment *pic in objects) {
                    
                    [_photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:pic.picture]]];
                }
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Ticker delegate

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

#pragma mark - Map delegate

- (void)cancelAllRequests
{
    if (!_isButtonTap) {
        
        [super cancelAllRequests];
        _isButtonTap = NO;   
        
        
    }
}

- (void)dealloc 
{
    
    [self cancelAllRequests];
    
    _delegateBack = nil;
    
    _user = nil;
    _event = nil;
    _eventLoader = nil;
    
    _map = nil;

    _header = nil;
    _headerDateLabel = nil;
    _headerGroupLabel = nil;
    _headerNameLabel = nil;
    _headerLocationLabel = nil;
    _headerTimeLabel = nil;
    _headerDistanceLabel = nil;
    _headerVoteLabel = nil;
    _headerAddButton = nil;
    _headerScore = nil;
    _rsvp = nil;
    _voteLoading = nil;
    _borderLeft = nil;
    _borderRight = nil;
    _labelFemaleRatio = nil;
    _labelMaleRatio = nil;
    _labelTotalAttendings = nil;
    _venueCategory = nil;
    _backButton = nil;
    _ticker = nil;
    
    _headerImage = nil;
    _map = nil;
    _mapImage = nil;
    
    
    
    _actVote = nil;
    _actRatio1 = nil;
    _actRatio2 = nil;
    _actRatio3 = nil;
    
    im = nil;
    
    _specialLabel = nil;
    _goodiesIcon = nil;
    _featuredIcon = nil;
    
    
    
    _segment = nil;
    
    _voteView = nil;
    _toolbar = nil;
    _eventLoader = nil;
    _picturesLoader = nil;
    
    _friendsSharedTo = nil;
    _tickerItems = nil;
}

#pragma mark - TKDragViewDelegate

- (void)dragViewDidStartDragging:(TKDragView *)dragView{
    
    [UIView animateWithDuration:0.2 animations:^{
        dragView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }];
}

- (void)dragViewDidEndDragging:(TKDragView *)dragView{
    
    [UIView animateWithDuration:0.2 animations:^{
        dragView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
}


- (void)dragViewDidEnterStartFrame:(TKDragView *)dragView{
    
    [UIView animateWithDuration:0.2 animations:^{
        dragView.alpha = 0.5;
    }];
}

- (void)dragViewDidLeaveStartFrame:(TKDragView *)dragView{
    
    [UIView animateWithDuration:0.2 animations:^{
        dragView.alpha = 1.0;
    }];
}


- (void)dragViewDidEnterGoodFrame:(TKDragView *)dragView atIndex:(NSInteger)index{
    
    UIView *view = [self.goodFrames objectAtIndex:index];
    
    if (view) view.layer.borderWidth = 4.0f;
    
    
}

- (void)dragViewDidLeaveGoodFrame:(TKDragView *)dragView atIndex:(NSInteger)index{    
    UIView *view = [self.goodFrames objectAtIndex:index];
    
    if (view) view.layer.borderWidth = 1.0f;
}


- (void)dragViewDidEnterBadFrame:(TKDragView *)dragView atIndex:(NSInteger)index{
    
    UIView *view = [self.badFrames objectAtIndex:index];
    
    if (view) view.layer.borderWidth = 4.0f;
}

- (void)dragViewDidLeaveBadFrame:(TKDragView *)dragView atIndex:(NSInteger)index{
    
    UIView *view = [self.badFrames objectAtIndex:index];
    
    if (view) view.layer.borderWidth = 1.0f;
}


- (void)dragViewWillSwapToEndFrame:(TKDragView *)dragView atIndex:(NSInteger)index{
    
    
    
}

- (void)dragViewDidSwapToEndFrame:(TKDragView *)dragView atIndex:(NSInteger)index{
    
    
    [UIView animateWithDuration:0.4
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         dragView.transform = CGAffineTransformMakeRotation(M_PI);
                     } 
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.4
                                               delay:0.1
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              dragView.transform = CGAffineTransformMakeRotation(M_PI);
                                          } 
                                          completion:^(BOOL finished) {
                                              
                                              
                                          }];
                     }];
    
    // send vote
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:[NSNumber numberWithInt:1] forKey:@"vote"];
    [params setValue:_user.uid forKey:@"userID"];
    [params setValue:_event.eid forKey:@"eventID"];
    [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
    
    _event.delegate = self;
    [_event vote:params success:@selector(onVoteSuccess:) failure:@selector(onVoteFailure:) sender:_voteView];
    
    [_actVote startAnimating];
}


- (void)dragViewWillSwapToStartFrame:(TKDragView *)dragView{
    [UIView animateWithDuration:0.2 animations:^{
        dragView.alpha = 1.0f; 
    }];
}

- (void)dragViewDidSwapToStartFrame:(TKDragView *)dragView{
    
}

@end
