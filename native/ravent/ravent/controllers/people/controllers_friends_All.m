//
//  controllers_friends_All.m
//  ravent
//
//  Created by florian haftman on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_friends_All.h"
#import "MBProgressHUD.h"
#import "YRDropdownView.h"
#import "ActionDispatcher.h"
#import "controllers_App.h"

@implementation controllers_friends_All

static controllers_friends_All *_ctrl;

@synthesize peekLeftAmount;
@synthesize following = _following;

- (id)initWithUser:(models_User *)user following:(NSMutableDictionary *)following
{
    self = [super init];
    
    if (self != nil) {
        
        [[NSBundle mainBundle] loadNibNamed:@"views_friends_item_All" owner:self options:nil];
        
        _user = user;
        _user.delegate = self;
        _user.callback = @selector(onLoadAll:);
        
        _following = following;
        
        [self loadData];
    }
    
    return self;
}

- (void)loadData
{
    if (_following != nil && [_following count] > 0) {
        
        [self loadData:NO];   
    }
}

- (void)loadData:(BOOL)force
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:_user.accessToken forKey:@"access_token"];
    [params setValue:_user.uid forKey:@"userID"];
    [_user loadAllWithParams:params force:force];
}

- (void)reloadTableViewDataSource
{
	_reloading = YES;
    [self loadData:YES];
}

- (void)onLoadAll:(NSArray *)objects
{    
    [self onLoadData:objects withSuccess:^ {
        
        _data = objects;
        _groupedData = [models_User getGroupedData:_data];
        _sortedKeys = [[_groupedData allKeys] sortedArrayUsingSelector:@selector(compare:)];
        
        for (int i = 0; i < [[_following allKeys] count]; i++) {
            
            NSString *key = [[_following allKeys]objectAtIndex:i];
            NSMutableArray *users = [_following objectForKey:key];
            
            for (int j = 0; j < [users count]; j++) {
                
                models_User *followedUser = [users objectAtIndex:j];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid like %@", followedUser.uid];
                
                NSArray *result = [[_groupedData objectForKey:key] filteredArrayUsingPredicate:predicate];
                
                ((models_User *)[result objectAtIndex:0]).isFollowed = @"true";
            }
        }
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_isSearching) {
        
        return @"";
    } else {
     
        NSString *key = [_sortedKeys objectAtIndex:section];
        
        if (key != nil) {
            
            return [NSString stringWithFormat:@"%@", key];
        } else {
            
            return @"";
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // nothing to do here
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    models_User *u = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        u = [_filteredData objectAtIndex:indexPath.row];
    }
    else
    {
        NSString *section = [_sortedKeys objectAtIndex:indexPath.section];
        NSMutableArray *rows = [_groupedData objectForKey:section];
        u = [rows objectAtIndex:indexPath.row];
    }
    
    
    [[NSBundle mainBundle] loadNibNamed:@"views_friends_item_All" owner:self options:nil];
    
    _itemTitle.text = [NSString stringWithFormat:@"%@ %@", u.firstName, u.lastName];
    _itemImage.imageURL = [NSURL URLWithString:u.picture];
    _itemImage.clipsToBounds = YES;
    _itemImage.contentMode = UIViewContentModeScaleAspectFill;
    
    if ([u.isFollowed isEqualToString:@"true"]) {
        
        [_switch setOn:YES];
    } else {
        [_switch setOn:NO];        
    }
    
    [cell.contentView addSubview:_item];
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (!_isSearching) {
        
        return _sortedKeys;
    } else {
        
        return nil;
    }
}

- (IBAction)onValueChanged:(id)sender
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:_user.uid forKey:@"userID"];
    
    UIView *parentView = [sender superview];
    while (! [parentView isKindOfClass:[UITableViewCell class]]) {
        
        parentView = [parentView superview];
    }
    UITableViewCell *cell = (UITableViewCell*)parentView;
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    
    NSString *key = [_sortedKeys objectAtIndex:path.section];
    NSMutableArray *rows = [_groupedData objectForKey:key];
    
    models_User *friend = [rows objectAtIndex:path.row]; 
    
    [params setValue:friend.uid forKey:@"friendID"];
    
    UISwitch *s = (UISwitch *)sender;
    
    if (!s.isOn) {
        
        [_user unfollow:params success:@selector(onFollowSuccess:) failure:@selector(onFollowFailure:) sender:sender];
        friend.isFollowed = @"false";
    } else {
        
        [_user follow:params success:@selector(onFollowSuccess:) failure:@selector(onFollowFailure:) sender:sender];
    }
    
    _isDirty = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _isDirty = NO;
}

- (void)onFollowSuccess:(NSString *)response
{
    _isDirty = YES;
}

- (void)onFollowFailure:(NSMutableDictionary *)response
{
    NSString *errorMsg = (NSString *)[response valueForKey:@"statusCode"];
    UISwitch *sender = (UISwitch *)[response valueForKey:@"sender"];
    
    [sender setOn:![sender isOn] animated:YES];
    
    [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                 title:@"Error" 
                                detail:errorMsg
                                 image:[UIImage imageNamed:@"dropdown-alert"]
                              animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.tableView.tableFooterView = [[UIView alloc] init];

    self.peekLeftAmount = 40.0f;
    [self.slidingViewController setAnchorLeftPeekAmount:self.peekLeftAmount];
    self.slidingViewController.underRightWidthLayout = ECVariableRevealWidth;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [super searchBarTextDidBeginEditing:searchBar];
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECLeft animations:^{
        CGRect frame = self.view.frame;
        frame.origin.x = 0.0f;
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            frame.size.width = [UIScreen mainScreen].bounds.size.height;
        } else if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            frame.size.width = [UIScreen mainScreen].bounds.size.width;
        }
        self.view.frame = frame;
    } onComplete:nil];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [super searchBarTextDidEndEditing:searchBar];
    
    [self.slidingViewController anchorTopViewTo:ECLeft animations:^{
        CGRect frame = self.view.frame;
        frame.origin.x = self.peekLeftAmount;
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            frame.size.width = [UIScreen mainScreen].bounds.size.height - self.peekLeftAmount;
        } else if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            frame.size.width = [UIScreen mainScreen].bounds.size.width - self.peekLeftAmount;
        }
        self.view.frame = frame;
    } onComplete:nil];
}

- (void)hideAllModal
{
    [self dismissModalViewControllerAnimated:YES];
    
    
    if (_user != nil) {
        
        [_user cancelAllRequests];
    }
    
    if (_event != nil) {
        
        [_event cancelAllRequests];
    }
    
    if (_isDirty) {
        
        [[ActionDispatcher instance] execute:@"reloadFollowing"];
    }
}

+ (controllers_friends_All *)instance:(NSMutableDictionary *)following
{
    if (_ctrl == nil) {
        
        _ctrl = [[controllers_friends_All alloc] initWithUser:[[models_User crtUser] copy] following:following];
    } else {
        
        _ctrl.following = following;
        
        if (_ctrl.groupedData == nil || [_ctrl.groupedData count] == 0) {
            
            [_ctrl reloadTableViewDataSource];
        } else {
         
            [_ctrl.tableView reloadData];
        }
    }
    
    return _ctrl;
}

@end
