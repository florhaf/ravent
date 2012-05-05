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
#import "controllers_friends_share.h"
#import "controllers_events_Description.h"
#import "controllers_events_FeedContainer.h"
#import "controllers_events_Details_Map.h"

@implementation controllers_events_Details

- (id)initWithEvent:(models_Event *)event
{
    self = [super initWithEvent:event];
    
    if (self != nil) {
        
        [[NSBundle mainBundle] loadNibNamed:@"views_events_Details" owner:self options:nil];
        
        _headerSize = CGSizeMake(_header.frame.size.width, _header.frame.size.height);
        _headerTitleSize = CGSizeMake(_headerNameLabel.frame.size.width, _headerNameLabel.frame.size.height);
        _headerSubTitleSize = CGSizeMake(_headerLocationLabel.frame.size.width, _headerLocationLabel.frame.size.height);
    }
    
    return self;
}

#pragma mark - Button event handler

- (IBAction)addToListButton_Tap:(id)sender
{
    NSLog(@"add to list");
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

- (void)newRating:(int)rating {

    [_voteLoading setHidden:NO];
    [_header bringSubviewToFront:_voteLoading];
    [_header sendSubviewToBack:_voteView];
    [((UIActivityIndicatorView *)[_voteLoading.subviews objectAtIndex:0]) startAnimating];
        
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:[NSNumber numberWithInt:rating] forKey:@"vote"];
    [params setValue:_user.uid forKey:@"userID"];
    [params setValue:_event.eid forKey:@"eventID"];
    
    _event.delegate = self;
    [_event vote:params success:@selector(onVoteSuccess:) failure:@selector(onVoteFailure:) sender:_voteView];
}

- (void)onVoteSuccess:(NSString *)response
{
    [_voteLoading setHidden:YES];
    
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
       
    [[NSBundle mainBundle] loadNibNamed:@"views_events_Details" owner:self options:nil];
        
    _headerDateLabel.text = [NSString stringWithFormat:@"%@ (%@ to %@)", _event.groupTitle, _event.dateStart, _event.dateEnd];
    _headerNameLabel.text = _event.name;
    _headerLocationLabel.text = _event.location;
    _headerImage.imageURL = [NSURL URLWithString:_event.picture];
    _headerTimeLabel.text = [NSString stringWithFormat:@"%@ - %@", _event.timeStart, _event.timeEnd];
    _headerDistanceLabel.text = [NSString stringWithFormat:@"%@ mi.", _event.distance];
    
    for (int i = 0; i < [_event.score intValue]; i++) {
        
        UIImageView *image = (UIImageView *)[_headerScore.subviews objectAtIndex:i];
        image.image = [UIImage imageNamed:@"like"];
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
    
    [_headerNameLabel sizeToFit];
    [_headerLocationLabel sizeToFit];
    
    CGFloat delta;
    
    delta = _headerNameLabel.frame.size.height - _headerTitleSize.height;
    if (delta > 0) {
        
        NSMutableArray *subviewsBelowTitle = [self subviews:_header.subviews BelowView:_headerNameLabel];
        
        for (int i = 0; i < [subviewsBelowTitle count]; i++) {
            
            UIView *subview = [subviewsBelowTitle objectAtIndex:i];
            subview.frame = CGRectMake(subview.frame.origin.x, subview.frame.origin.y + delta, subview.frame.size.width, subview.frame.size.height);
        }
    }
    _header.frame = CGRectMake(_header.frame.origin.x, _header.frame.origin.y, _header.frame.size.width, _header.frame.size.height + delta);
    
    delta = _headerLocationLabel.frame.size.height - _headerSubTitleSize.height;
    if (delta > 0) {
        
        NSMutableArray *subviewsBelowSubTitle = [self subviews:_header.subviews BelowView:_headerLocationLabel];
        for (int i = 0; i < [subviewsBelowSubTitle count]; i++) {
            
            UIView *subview = [subviewsBelowSubTitle objectAtIndex:i];
            subview.frame = CGRectMake(subview.frame.origin.x, subview.frame.origin.y + delta, subview.frame.size.width, subview.frame.size.height);
        }
    }
    _header.frame = CGRectMake(_header.frame.origin.x, _header.frame.origin.y, _header.frame.size.width, _header.frame.size.height + delta);
    
    self.tableView.tableHeaderView = _header;
}

@end
