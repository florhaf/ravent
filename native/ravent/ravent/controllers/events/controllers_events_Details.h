//
//  controllers_events_Details.h
//  ravent
//
//  Created by florian haftman on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewFriends.h"
#import "MWPhotoBrowser.h"
#import "models_Comment.h"
#import "STSegmentedControl.h"
#import "MKTickerView.h"
#import "TKDragView.h"

typedef enum {
    nogoodies,
    onegoodies,
    twogoodies
} detailsVersion;

@interface controllers_events_Details : UITableViewFriends<MWPhotoBrowserDelegate, MKTickerViewDataSource, MKMapViewDelegate, MKAnnotation, TKDragViewDelegate> {
        
    CGSize _headerSize;
    CGSize _headerTitleSize;
    CGSize _headerSubTitleSize;
    
    IBOutlet UIView *_header;
    IBOutlet UILabel *_headerDateLabel;
    IBOutlet UILabel *_headerGroupLabel;
    IBOutlet UILabel *_headerNameLabel;
    IBOutlet UILabel *_headerLocationLabel;
    IBOutlet UILabel *_headerTimeLabel;
    IBOutlet UILabel *_headerDistanceLabel;
    IBOutlet UILabel *_headerVoteLabel;
    IBOutlet UIButton *_headerAddButton;
    IBOutlet UIView *_headerScore;
    IBOutlet UISegmentedControl *_rsvp;
    IBOutlet UIView *_voteLoading;
    IBOutlet UIImageView *_borderLeft;
    IBOutlet UIImageView *_borderRight;
    IBOutlet UILabel *_labelFemaleRatio;
    IBOutlet UILabel *_labelMaleRatio;
    IBOutlet UILabel *_labelTotalAttendings;
    IBOutlet UILabel *_venueCategory;
    IBOutlet UIButton *_backButton;
    IBOutlet MKTickerView *_ticker;
    
    IBOutlet JBAsyncImageView *_headerImage;
    IBOutlet MKMapView *_map;
    IBOutlet UIView *_mapImage;
    MKCoordinateRegion _viewRegion;
    CLLocationCoordinate2D _zoomLocation;
    
    IBOutlet UIActivityIndicatorView *_actVote;
    IBOutlet UIActivityIndicatorView *_actRatio1;
    IBOutlet UIActivityIndicatorView *_actRatio2;
    IBOutlet UIActivityIndicatorView *_actRatio3;
    
    IBOutlet UILabel *im;
    
    IBOutlet UILabel *_specialLabel;
    IBOutlet UIImageView *_goodiesIcon;
    IBOutlet UIImageView *_featuredIcon;
    IBOutlet UILabel *_dropagemLabel;
    
    detailsVersion _detailsVersion;
    
    STSegmentedControl *_segment;
    TKDragView *_dragView;

    UIToolbar *_toolbar;
    models_Event *_eventLoader;
    models_Comment *_picturesLoader;
    
    NSArray *_friendsSharedTo;
    NSArray *_tickerItems;
    BOOL _isButtonTap;
    BOOL _isMapImageSet;
    int _mapImageHeight;

    
    id __weak _delegateBack;
    SEL _selectorBack;
}

@property (nonatomic, retain) NSMutableArray *photos;
@property (nonatomic, weak) id delegateBack;
@property (nonatomic, assign) SEL selectorBack;

@property (nonatomic, strong) NSMutableArray *dragViews;
@property (nonatomic, strong) NSMutableArray *goodFrames;
@property (nonatomic, strong) NSMutableArray *badFrames;
@property BOOL canDragMultipleViewsAtOnce;
@property BOOL canUseTheSameFrameManyTimes;

- (id)initWithReloadEvent:(models_Event *)event;
- (id)initWithEvent:(models_Event *)event withBackDelegate:(id)delegate backSelector:(SEL)sel;

- (IBAction)addToListButton_Tap:(id)sender;
- (IBAction)snap_Tap:(id)sender;
- (IBAction)mapButton_Tap:(id)sender;
- (IBAction)picButton_Tap:(id)sender;
- (IBAction)rsvp:(id)sender;
- (IBAction)backButton_Tap:(id)sender;
- (IBAction)onTicket_Tap:(id)sender;
- (IBAction)onSpecials_Tap:(id)sender;
- (IBAction)onGoodies_Tap:(id)sender;

- (void)onVoteSuccess:(NSString *)response;
- (void)onVoteFailure:(NSMutableDictionary *)response;

@end
