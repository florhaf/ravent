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
#import "MBProgressHUD.h"
#import "EGORefreshTableHeaderView.h"
#import "JBAsyncImageView.h"
#import "utils.h"
#import "GANTracker.h"


typedef void (^success)();

@interface UITableViewReloadable : UITableViewController <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource, JBAsyncImageViewDelegate> {
    
    models_User *_user;
    models_Event *_event;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    IBOutlet UIView *_emptyView;
    IBOutlet UIView *_emptyMessageViewPlaceHolder;
    IBOutlet UIView *_emptyImageView;
    IBOutlet UIView *_item;
    IBOutlet UILabel *_itemTitle;
    IBOutlet UILabel *_itemSubTitle;
    IBOutlet JBAsyncImageView *_itemImage;
    IBOutlet UIActivityIndicatorView *_spinner;
    
    CGSize _itemSize;
    CGSize _titleSize;
    CGSize _subTitleSize;
    
    BOOL _reloading;
    BOOL _isDirty;
    BOOL _showEmptyMessage;
    BOOL _isNotReloadable;
    IBOutlet UIView *_emptyMessageView;
    
    NSArray *_data;
    NSArray *_sortedKeys;
    NSMutableDictionary *_groupedData;
    
    NSString *_url;
    MBProgressHUD *_hud;
    
    NSMutableDictionary *_imagesCache;
}

@property (nonatomic, retain) NSArray *data;
@property (nonatomic, retain) NSMutableDictionary *groupedData;
@property (nonatomic, retain) NSString *emptyMessage;

- (NSDate *)lastLoadTime;
- (void)trackPageView:(NSString *)named forEvent:(NSString *)eid;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

- (void)loadData;
- (void)loadDataWithSpinner;
- (void)onLoadData:(NSArray *)objects withSuccess:(success)success;
- (id)getObjForSection:(NSInteger)section andRow:(NSInteger)row;

- (void)updateLoadingMessageWith:(NSString *)text;

- (NSMutableArray *)subviews:(NSArray *)subviews BelowView:(UIView *)view;
- (CGFloat)resizeAndPositionCellItem;
- (int)getFontSizeForLabel:(UILabel *)label;

- (void)cancelAllRequests;

@end
