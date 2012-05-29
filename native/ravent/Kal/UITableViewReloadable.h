//
//  UITableViewReloadable.h
//  ravent
//
//  Created by florian haftman on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h> 



#import "EGORefreshTableHeaderView.h"

typedef void (^success)();

@interface UITableViewReloadable : UITableViewController <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource> {

    
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    IBOutlet UIView *_emptyView;
    IBOutlet UIView *_item;
    IBOutlet UILabel *_itemTitle;
    IBOutlet UILabel *_itemSubTitle;

    
    CGSize _itemSize;
    CGSize _titleSize;
    CGSize _subTitleSize;
    
    BOOL _reloading;
    BOOL _isDirty;
    
    NSArray *_data;
    NSArray *_sortedKeys;
    NSMutableDictionary *_groupedData;
}

@property (nonatomic, retain) NSMutableDictionary *groupedData;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

- (void)loadData;
- (void)loadDataWithSpinner;
- (void)onLoadData:(NSArray *)objects withSuccess:(success)success;

- (NSMutableArray *)subviews:(NSArray *)subviews BelowView:(UIView *)view;
- (CGFloat)resizeAndPositionCellItem;

- (void)cancelAllRequests;

@end
