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

@interface controllers_events_Details : UITableViewFriends<DLStarRatingDelegate> {
        
    CGSize _headerSize;
    CGSize _headerTitleSize;
    CGSize _headerSubTitleSize;
    
    IBOutlet UIView *_header;
    IBOutlet UILabel *_headerDateLabel;
    IBOutlet UILabel *_headerNameLabel;
    IBOutlet UILabel *_headerLocationLabel;
    IBOutlet UILabel *_headerTimeLabel;
    IBOutlet UILabel *_headerDistanceLabel;
    IBOutlet UILabel *_headerVoteLabel;
    IBOutlet UIButton *_headerAddButton;
    
    IBOutlet JBAsyncImageView *_headerImage;
    IBOutlet JBAsyncImageView *_mapImage;
    
    DLStarRatingControl *_voteView;
}

- (IBAction)addToListButton_Tap:(id)sender;
- (IBAction)shareButton_Tap:(id)sender;
- (IBAction)descriptionButton_Tap:(id)sender;
- (IBAction)feedButton_Tap:(id)sender;
- (IBAction)mapButton_Tap:(id)sender;

@end
