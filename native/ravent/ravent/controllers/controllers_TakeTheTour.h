//
//  controllers_TakeTheTour.h
//  ravent
//
//  Created by florian haftman on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKDragView.h"

@interface controllers_TakeTheTour : UIViewController<TKDragViewDelegate> {
    
    IBOutlet UIView *_container;
    IBOutlet UIButton *_next;
    
    IBOutlet UIImageView *_lightBurst;
    
    int _currentNbOfBurst;
    int _maxNbOfBurst;
    
    TKDragView *_dragView;
}

@property (nonatomic, strong) NSMutableArray *dragViews;
@property (nonatomic, strong) NSMutableArray *goodFrames;
@property (nonatomic, strong) NSMutableArray *badFrames;
@property BOOL canDragMultipleViewsAtOnce;
@property BOOL canUseTheSameFrameManyTimes;

@property (nonatomic, retain) UIView *container;
@property (nonatomic, retain) UIButton *next;

- (IBAction)next:(id)sender;
- (IBAction)no:(id)sender;

+ (controllers_TakeTheTour *)instance;


@end
