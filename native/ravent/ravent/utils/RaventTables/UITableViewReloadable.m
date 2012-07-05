//
//  UITableViewReloadable.m
//  ravent
//
//  Created by florian haftman on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITableViewReloadable.h"

#import "YRDropdownView.h"
#import "JBAsyncImageView.h"
#import "controllers_App.h"
#import "ActionDispatcher.h"
#import <RestKit/RKErrorMessage.h>

typedef enum {
    
    invited,
    eventsP2P,
    eventsUser,
    followings,
    followers,
    empty
} emptyMessage;

@implementation UITableViewReloadable

@synthesize data = _data;
@synthesize groupedData = _groupedData;
@synthesize emptyMessage = _emptyMessage;

- (id)init
{
    self = [super init];
    if (self) {
        
        self.title = @"Gemster";
        _showEmptyMessage = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    _imagesCache = nil;
    
    _imagesCache = [[NSMutableDictionary alloc] init];
}

- (void)updateLoadingMessageWith:(NSString *)text
{
    
    if (_hud != nil) {
        
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        [MBProgressHUD showHUDAddedTo:self.view animated:NO withText:text];
    }
    
    _refreshHeaderView.statusLabel.text = text;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_imagesCache == nil) {
     
        _imagesCache = [[NSMutableDictionary alloc] init];
    }
    
    if (!_isNotReloadable) { 
        
        if(_refreshHeaderView == nil) {
		
            EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
            view.delegate = self;
            _refreshHeaderView = view;
            
            UIImageView *tableTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableTop"]];
            [tableTop setFrame:CGRectMake(0, _refreshHeaderView.frame.size.height - 21, 320, 21)];
            
            [_refreshHeaderView addSubview:tableTop];
            [_refreshHeaderView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"grayBG"]]];
        }
	
        [_refreshHeaderView refreshLastUpdatedDate];
    }
    
    [self.tableView addSubview:_refreshHeaderView];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"grayBG"]]];
    
    [[NSBundle mainBundle] loadNibNamed:@"views_Empty" owner:self options:nil];
    self.tableView.tableFooterView = _emptyView;
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
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadData];
}

- (void)onLoadData:(NSArray *)objects withSuccess:(success)success
{
    _data = nil;
    _groupedData = nil;
    _sortedKeys = nil;

    
    
    if (_url != nil) {
    
        [[ActionDispatcher instance] del:_url];
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    _hud = nil;
    
    if (objects != nil && [objects count] > 0) {
        
        id object = [objects objectAtIndex:0];
        
        if ([object isKindOfClass:[NSError class]]) {
            
            NSError *error = (NSError *)object;
            
            [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                         title:@"Error" 
                                        detail:[error localizedDescription]
                                         image:[UIImage imageNamed:@"dropdown-alert"]
                                      animated:YES];
            
            [[NSBundle mainBundle] loadNibNamed:@"views_Empty_Generic" owner:self options:nil];
            ((UILabel *)[_emptyMessageView.subviews objectAtIndex:0]).text = @"pull to refresh";
            [_emptyMessageViewPlaceHolder addSubview:_emptyMessageView];
            
            [self.tableView reloadData];
            
        } else if ([object isKindOfClass:[RKErrorMessage class]]) {
            
            RKErrorMessage *error = (RKErrorMessage *)object;
            
            [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                         title:@"Error" 
                                        detail:[error errorMessage]
                                         image:[UIImage imageNamed:@"dropdown-alert"]
                                      animated:YES];
            
            [[NSBundle mainBundle] loadNibNamed:@"views_Empty_Generic" owner:self options:nil];
            ((UILabel *)[_emptyMessageView.subviews objectAtIndex:0]).text = @"pull to refresh";
            [_emptyMessageViewPlaceHolder addSubview:_emptyMessageView];
            
            [self.tableView reloadData];
            
        } else {
            
            success();
            
            [self.tableView reloadData];
        }
    } else {
        
        if (_emptyMessageView != nil) {
            
            [_emptyMessageViewPlaceHolder addSubview:_emptyMessageView];
        }
        
        [self.tableView reloadData];
    }
    
    [self doneLoadingTableViewData];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{		
    if (!_isNotReloadable) {
     
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{	
    if (!_isNotReloadable) {
     
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
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
    NSString *str = [self tableView:tableView titleForHeaderInSection:section];
    
    if (str != nil && ![str isEqualToString:@""]) {
        return 16;
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
    label.frame = CGRectMake(10, 2, 300, 14);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:228 green:230 blue:234 alpha:1.0];
    label.shadowColor = [UIColor darkGrayColor];
    label.shadowOffset = CGSizeMake(0.0, 0.0);
    label.font = [UIFont systemFontOfSize:12];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 16)];
    
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

- (id)getObjForSection:(NSInteger)section andRow:(NSInteger)row
{
    if (_sortedKeys != nil && [_sortedKeys count] > 0) {
        
        NSString *key = [_sortedKeys objectAtIndex:section];
        
        if (key != nil) {
            
            if (_groupedData != nil) {
                
                NSArray *ar = [_groupedData valueForKey:key];
                
                if (ar != nil && [ar count] > 0) {
                    
                    id obj = [ar objectAtIndex:row];
                    return obj;         
                }
            }
        }
    }
    
    return nil;
}

-(void)imageView:(JBAsyncImageView *)sender loadedImage:(UIImage *)imageLoaded fromURL:(NSURL *)url
{
    if (imageLoaded != nil && url != nil) {
        
        [_imagesCache setObject:imageLoaded forKey:[NSString stringWithFormat:@"%@", url]];
    }
}

- (void)dealloc
{
    _item = nil;
    _itemTitle = nil;
    _itemSubTitle = nil;
    _itemImage = nil;    
}

@end
