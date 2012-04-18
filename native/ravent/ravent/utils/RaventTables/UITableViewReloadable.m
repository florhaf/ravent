//
//  UITableViewReloadable.m
//  ravent
//
//  Created by florian haftman on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITableViewReloadable.h"

#import "MBProgressHUD.h"
#import "YRDropdownView.h"

@implementation UITableViewReloadable

@synthesize groupedData = _groupedData;

- (id)init
{
    self = [super init];
    if (self) {
        
        self.title = @"Ravent";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
	
	[_refreshHeaderView refreshLastUpdatedDate];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)cancelAllRequests
{
    if (_user != nil) {
            
        [_user cancelAllRequests];
    }
    
    if (_event != nil) {
        
        [_event cancelAllRequests];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadData
{
    // must be overriden in subclass
}

- (void)loadDataWithSpinner
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadData];
}

- (void)onLoadData:(NSArray *)objects withSuccess:(success)success
{
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    if ([objects count] > 0) {
        
        id object = [objects objectAtIndex:0];
        
        if ([object isKindOfClass:[NSError class]]) {
            
            NSError *error = (NSError *)object;
            
            [YRDropdownView showDropdownInView:self.view 
                                         title:@"Error" 
                                        detail:[error localizedDescription]
                                         image:[UIImage imageNamed:@"dropdown-alert"]
                                      animated:YES];
        } else {
            
            success();
            
            [self.tableView reloadData];
        }
    } else {
        
        [[NSBundle mainBundle] loadNibNamed:@"views_Empty" owner:self options:nil];
        self.tableView.tableFooterView = _emptyView;
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [self doneLoadingTableViewData];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{		
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
    [MBProgressHUD hideHUDForView:self.view animated:YES];
	[self reloadTableViewDataSource];	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource
{
	_reloading = YES;
    [self loadData];
}

- (void)doneLoadingTableViewData
{
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _item.frame.size.height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_groupedData != NULL && [_groupedData count] > 0) {
        
        return [[_groupedData allKeys] count];
    } else {
        
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_groupedData != NULL && [_groupedData count] > 0) {
        
        NSString *key = [_sortedKeys objectAtIndex:section];
        NSMutableArray *rows = [_groupedData objectForKey:key];
        
        return [rows count];
    } else {
        
        return [_data count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        
        for (int i = 0; i < [cell.contentView.subviews count]; i++) {
            
            [[cell.contentView.subviews objectAtIndex:i] removeFromSuperview];
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSException *exception = [NSException exceptionWithName: @"Code error"
                                                     reason: @"this function must be overriden in subclass"
                                                   userInfo: nil];
    @throw exception;
}

- (NSMutableArray *)subviews:(NSArray *)subviews BelowView:(UIView *)view
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [subviews count]; i++) {
        
        UIView *subview = [subviews objectAtIndex:i];

        if (view != subview) {
         
            if (view.frame.origin.y < subview.frame.origin.y) {
                
                [result addObject:subview];
            }
        }
    }
    
    return result;
}

- (void)resizeAndPositionCellItem
{
    [_itemTitle sizeToFit];
    [_itemSubTitle sizeToFit];
    
    CGFloat delta;
    
    delta = _itemTitle.frame.size.height - _titleSize.height;
    if (delta > 0) {
        
        NSMutableArray *subviewsBelowTitle = [self subviews:_item.subviews BelowView:_itemTitle];
        
        for (int i = 0; i < [subviewsBelowTitle count]; i++) {
            
            UIView *subview = [subviewsBelowTitle objectAtIndex:i];
            subview.frame = CGRectMake(subview.frame.origin.x, subview.frame.origin.y + delta, subview.frame.size.width, subview.frame.size.height);
        }
    }
    
    delta = _itemSubTitle.frame.size.height - _subTitleSize.height;
    if (delta > 0) {
        
        NSMutableArray *subviewsBelowSubTitle = [self subviews:_item.subviews BelowView:_itemSubTitle];
        for (int i = 0; i < [subviewsBelowSubTitle count]; i++) {
            
            UIView *subview = [subviewsBelowSubTitle objectAtIndex:i];
            subview.frame = CGRectMake(subview.frame.origin.x, subview.frame.origin.y + delta, subview.frame.size.width, subview.frame.size.height);
        }
    }
}

@end
