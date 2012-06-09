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
#import "JBAsyncImageView.h"
#import "controllers_App.h"

@implementation UITableViewReloadable

@synthesize groupedData = _groupedData;
@synthesize emptyMessage = _emptyMessage;

- (id)init
{
    self = [super init];
    if (self) {
        
        self.title = @"Ravent";
        _showEmptyMessage = NO;
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
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
	
	[_refreshHeaderView refreshLastUpdatedDate];
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    bg.frame = self.tableView.frame;
    self.tableView.backgroundView = bg;
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
    [[NSBundle mainBundle] loadNibNamed:@"views_Empty" owner:self options:nil];
    self.tableView.tableFooterView = _emptyView;
    
    _data = nil;
    _groupedData = nil;
    _sortedKeys = nil;
    
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
            return;
        }
    }
    
    success();
        
    
    
    if (_showEmptyMessage == YES) {
        
        if (_emptyMessage != nil) {
            
            for (UIView *v in _emptyMessageView.subviews) {
                
                [v setHidden:YES];
            }
            
            UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
            l.text = _emptyMessage;
            l.backgroundColor = [UIColor clearColor];
            l.textColor = [UIColor lightGrayColor];
            l.font = [UIFont fontWithName:@"System Bold" size: 16.0];
            l.textAlignment = UITextAlignmentCenter;
            
            [_emptyMessageView addSubview:l];
        }
        
        [_emptyMessageView setHidden:NO];
    } else {
        
        [_emptyMessageView setHidden:YES];
    }
    
    [self.tableView reloadData];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self tableView:tableView titleForHeaderInSection:section] != nil) {
        return 21;;
    }
    else {
        // If no section header title, no section header needed
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // Create label with section title
    UILabel *label = [[UILabel alloc] init]; 
    label.frame = CGRectMake(10, 0, 300, 21);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:228 green:230 blue:234 alpha:1.0];
    label.shadowColor = [UIColor darkGrayColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 21)];
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sectionHeader"]];
    bg.frame = view.frame;
    bg.alpha = 0.9;
    
    [view addSubview:bg];
    [view addSubview:label];

    return view;
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

- (int)getFontSizeForLabel:(UILabel *)label
{
    /* This is where we define the ideal font that the Label wants to use.
     Use the font you want to use and the largest font size you want to use. */
    UIFont *font = [label.font fontWithSize:36];
    
    int i;
    /* Time to calculate the needed font size.
     This for loop starts at the largest font size, and decreases by two point sizes (i=i-2)
     Until it either hits a size that will fit or hits the minimum size we want to allow (i > 10) */
    for(i = 36; i > 10; i--)
    {
        // Set the new font size.
        font = [font fontWithSize:i];
        
        /* This step is important: We make a constraint box 
         using only the fixed WIDTH of the UILabel. The height will
         be checked later. */ 
        CGSize constraintSize = CGSizeMake(label.frame.size.width, MAXFLOAT);
        
        // This step checks how tall the label would be with the desired font.
        CGSize labelSize = [label.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        
        if(labelSize.height <= label.frame.size.height) {
            break;   
        }
    }
    
    return i;
}

- (CGFloat)resizeAndPositionCellItem
{
    [_itemTitle sizeToFit];
    [_itemSubTitle sizeToFit];
    
    CGFloat delta1 = _itemTitle.frame.size.height - _titleSize.height;
    if (delta1 > 0) {
        
        NSMutableArray *subviewsBelowTitle = [self subviews:_item.subviews BelowView:_itemTitle];
        
        for (int i = 0; i < [subviewsBelowTitle count]; i++) {
            
            UIView *subview = [subviewsBelowTitle objectAtIndex:i];
            
            if (subview.tag != 42) {
                
                subview.frame = CGRectMake(subview.frame.origin.x, subview.frame.origin.y + delta1, subview.frame.size.width, subview.frame.size.height);
            }
        }
    }
    
    CGFloat delta2 = _itemSubTitle.frame.size.height - _subTitleSize.height;
    if (delta2 > 0) {
        
        NSMutableArray *subviewsBelowSubTitle = [self subviews:_item.subviews BelowView:_itemSubTitle];
        for (int i = 0; i < [subviewsBelowSubTitle count]; i++) {
            
            UIView *subview = [subviewsBelowSubTitle objectAtIndex:i];
            
            if (subview.tag != 42) {
                
                subview.frame = CGRectMake(subview.frame.origin.x, subview.frame.origin.y + delta2, subview.frame.size.width, subview.frame.size.height);
            }
        }
    }
    
    return delta1 + delta2;
}

@end
