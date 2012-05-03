//
//  controllers_friends_Following.m
//  ravent
//
//  Created by florian haftman on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_friends_Following.h"
#import "MBProgressHUD.h"
#import "controllers_friends_Details.h"
#import "ActionDispatcher.h"

@implementation controllers_friends_Following

- (id)initWithUser:(models_User *)user isFollowing:(BOOL)value
{
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self != nil) {
        
        [[NSBundle mainBundle] loadNibNamed:@"views_friends_item_Following" owner:self options:nil];
        
        _isFollowing = value;
        _user = user;
        _user.delegate = self;
        _user.callback = @selector(onLoadFollowings:);
        
        self.tableView.frame = CGRectMake(0, 0, 320, 392);
        self.tableView.tableFooterView = [[UIView alloc] init];

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self loadData];
    }
    
    return self;
}

- (void)loadData
{    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    NSString *isFollowingStr;
    if (_isFollowing) {
        
        isFollowingStr = @"true";
    } else {
        
        isFollowingStr = @"false";
    }

    [params setValue:_user.accessToken forKey:@"access_token"];
    [params setValue:_user.uid forKey:@"userID"];
    [params setValue:isFollowingStr forKey:@"isFollowing"];
    [_user loadFollowingsWithParams:params];
    
    [[ActionDispatcher instance]execute:@"reloadCurrentUser"];
}

- (void)onLoadFollowings:(NSArray *)objects
{   
    [self onLoadData:objects withSuccess:^ {
        
        _data = objects;
        _groupedData = [models_User getGroupedData:_data];
        _sortedKeys = [[_groupedData allKeys] sortedArrayUsingSelector:@selector(compare:)];
    }];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *key = [_sortedKeys objectAtIndex:section];
    
    if (key != nil) {
        
        return [NSString stringWithFormat:@"%@", key];
    } else {
        
        return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSString *section = [_sortedKeys objectAtIndex:indexPath.section];
    NSMutableArray *rows = [_groupedData objectForKey:section];
    models_User *u = [rows objectAtIndex:indexPath.row];
    
    [[NSBundle mainBundle] loadNibNamed:@"views_friends_item_Following" owner:self options:nil];
    
    _itemTitle.text = [NSString stringWithFormat:@"%@ %@", u.firstName, u.lastName];
    _itemImage.imageURL = [NSURL URLWithString:u.picture];
    
    _followersLabel.text = u.nbOfFollowers;
    _followingLabel.text = u.nbOfFollowing;
    _eventsLabel.text = u.nbOfEvents;
    
    [cell.contentView addSubview:_item];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *section = [_sortedKeys objectAtIndex:indexPath.section];
    NSMutableArray *rows = [_groupedData objectForKey:section];
    
    models_User *user = [rows objectAtIndex:indexPath.row];
    controllers_friends_Details *details = [[controllers_friends_Details alloc] initWithUser:[user copy]]; 
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: self action:nil];
    UIViewController *rootController = self;
    
    while (![rootController.parentViewController isKindOfClass:[UINavigationController class]]) {
        
        rootController = rootController.parentViewController;
    }
    
    [rootController.navigationItem setBackBarButtonItem: backButton];
    [self.navigationController pushViewController:details animated:YES];
}

@end
