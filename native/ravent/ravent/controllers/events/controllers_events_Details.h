//
//  controllers_events_Details.h
//  ravent
//
//  Created by florian haftman on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewFriends.h"
#import "DLStarRatingControl.h"
#import "MWPhotoBrowser.h"
#import "models_Comment.h"

@interface controllers_events_Details : UITableViewFriends<DLStarRatingDelegate, MWPhotoBrowserDelegate> {
        
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
    
    IBOutlet JBAsyncImageView *_headerImage;
    IBOutlet JBAsyncImageView *_mapImage;
    
    DLStarRatingControl *_voteView;
    UIToolbar *_toolbar;
    models_Event *_eventLoader;
    models_Comment *_picturesLoader;
    
    NSArray *_friendsSharedTo;
    BOOL _isButtonTap;
}

@property (nonatomic, retain) NSMutableArray *photos;

- (id)initWithReloadEvent:(models_Event *)event;

- (IBAction)addToListButton_Tap:(id)sender;
- (IBAction)shareButton_Tap:(id)sender;
- (IBAction)descriptionButton_Tap:(id)sender;
- (IBAction)feedButton_Tap:(id)sender;
- (IBAction)mapButton_Tap:(id)sender;
- (IBAction)picButton_Tap:(id)sender;
- (IBAction)rsvp:(id)sender;

- (void)onVoteSuccess:(NSString *)response;
- (void)onVoteFailure:(NSMutableDictionary *)response;

@end
