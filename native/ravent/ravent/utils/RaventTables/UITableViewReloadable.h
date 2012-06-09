//
//  UITableViewReloadable.h
//  ravent
//
//  Created by florian haftman on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h> 

#import "models_User.h"
#import "models_Event.h"

#import "EGORefreshTableHeaderView.h"
#import "JBAsyncImageView.h"

typedef void (^success)();

@interface UITableViewReloadable : UITableViewController <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    models_User *_user;
    models_Event *_event;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    IBOutlet UIView *_emptyView;
    IBOutlet UIView *_emptyMessageView;
    IBOutlet UIView *_emptyImageView;
    IBOutlet UIView *_item;
    IBOutlet UILabel *_itemTitle;
    IBOutlet UILabel *_itemSubTitle;
    IBOutlet JBAsyncImageView *_itemImage;
    
    CGSize _itemSize;
    CGSize _titleSize;
    CGSize _subTitleSize;
    
    BOOL _reloading;
    BOOL _isDirty;
    BOOL _showEmptyMessage;
    NSString *_emptyMessage;
    
    NSArray *_data;
    NSArray *_sortedKeys;
    NSMutableDictionary *_groupedData;
}

@property (nonatomic, retain) NSMutableDictionary *groupedData;
@property (nonatomic, retain) NSString *emptyMessage;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

- (void)loadData;
- (void)loadDataWithSpinner;
- (void)onLoadData:(NSArray *)objects withSuccess:(success)success;

- (NSMutableArray *)subviews:(NSArray *)subviews BelowView:(UIView *)view;
- (CGFloat)resizeAndPositionCellItem;
- (int)getFontSizeForLabel:(UILabel *)label;

- (void)cancelAllRequests;

@end
