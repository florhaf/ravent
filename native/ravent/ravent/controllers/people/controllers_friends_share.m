//
//  controllers_friends_share.m
//  ravent
//
//  Created by florian haftman on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_friends_share.h"
#import "MBProgressHUD.h"
#import "ActionDispatcher.h"

@implementation controllers_friends_share

- (id)initWithUser:(models_User *)user invited:(NSMutableArray *)invited
{
    self = [super init];
    
    if (self != nil) {
        
        [[NSBundle mainBundle] loadNibNamed:@"views_friends_item_Share" owner:self options:nil];
        
        _user = user;
        _user.delegate = self;
        _user.callback = @selector(onLoadAll:);
        
        _invited = invited;
        
        self.title = @"Ravent";
        
        [self loadData];
    }
    
    return self;
}

- (void)loadData
{
    [self loadData:NO];
}

- (void)loadData:(BOOL)force
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:_user.accessToken forKey:@"access_token"];
    [params setValue:_user.uid forKey:@"userID"];
    [_user loadShareWithParams:params force:force];
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

        for (int j = 0; j < [_invited count]; j++) {
            
            models_User *invitedUser = [_invited objectAtIndex:j];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid like %@", invitedUser.uid];
            
            NSArray *result = [objects filteredArrayUsingPredicate:predicate];
            
            ((models_User *)[result objectAtIndex:0]).isInvited = @"true";
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
    
    [[NSBundle mainBundle] loadNibNamed:@"views_friends_item_Share" owner:self options:nil];
    
    _itemTitle.text = [NSString stringWithFormat:@"%@ %@", u.firstName, u.lastName];
    _itemImage.imageURL = [NSURL URLWithString:u.picture];
    
    if ([u.isInvited isEqualToString:@"true"]) {
        
        [_inviteButton setEnabled:NO];
        _inviteButton.titleLabel.text = @"Invited";
    }
    
    [cell.contentView addSubview:_item];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // nothing to do here
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    return _sortedKeys;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *donei = [UIImage imageNamed:@"doneButton"];
    UIButton *doneb = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneb addTarget:self action:@selector(hideAllModal) forControlEvents:UIControlEventTouchUpInside];
    [doneb setImage:donei forState:UIControlStateNormal];
    [doneb setFrame:CGRectMake(0, 0, donei.size.width, donei.size.height)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithCustomView:doneb];       
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
}

@end
