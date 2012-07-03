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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFollowingLoaded:) name:@"followingLoaded" object:nil];
        
        [self loadData];
    }
    
    return self;
}

- (void)onFollowingLoaded:(NSNotification *)notification
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    _following = [[NSMutableDictionary alloc] initWithDictionary:[notification userInfo]];
    
    if (_following != nil) {
        
        for (int i = 0; i < [[_following allKeys] count]; i++) {
            
            NSString *key = [[_following allKeys]objectAtIndex:i];
            
            if (key != nil) {
             
                NSMutableArray *users = [_following objectForKey:key];
                
                if (users != nil) {
                    
                    for (int j = 0; j < [users count]; j++) {
                        
                        models_User *followedUser = [users objectAtIndex:j];
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid like %@", followedUser.uid];
                        
                        NSArray *result = [[_groupedData objectForKey:key] filteredArrayUsingPredicate:predicate];
                        
                        ((models_User *)[result objectAtIndex:0]).isFollowed = @"true";
                    }
                }
            }
        }
    }
    
    [self.tableView reloadData];
}

- (void)loadData
{
    //if (_following != nil && [_following count] > 0) {
        
        [self loadData:NO];   
    //}
}

- (void)loadData:(BOOL)force
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:_user.accessToken forKey:@"access_token"];
    [params setValue:_user.uid forKey:@"userID"];
    
    _url = [@"friends" appendQueryParams:params];
    Action *upadteLoadingMessageAction = [[Action alloc] initWithDelegate:self andSelector:@selector(updateLoadingMessageWith:)];
    [[ActionDispatcher instance] add:upadteLoadingMessageAction named:_url];
    
    [_user loadAllWithParams:params force:force];
}

- (void)reloadTableViewDataSource
{
	_reloading = YES;
    [self reloadTableViewDataSource:YES];
}

- (void)reloadTableViewDataSource:(BOOL)force
{
	_reloading = YES;
    [self loadData:force];
}

- (void)onLoadAll:(NSArray *)objects
{    
    [self onLoadData:objects withSuccess:^ {
        
        _data = objects;
        _groupedData = [models_User getGroupedData:_data];
        _sortedKeys = [[_groupedData allKeys] sortedArrayUsingSelector:@selector(compare:)];
        
        if (_following != nil) {
            
            for (int i = 0; i < [[_following allKeys] count]; i++) {
                
                NSString *key = [[_following allKeys]objectAtIndex:i];
                
                if (key != nil) {
                    
                    NSMutableArray *users = [_following objectForKey:key];
                    
                    for (int j = 0; j < [users count]; j++) {
                        
                        models_User *followedUser = [users objectAtIndex:j];
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid like %@", followedUser.uid];
                        
                        NSArray *result = [[_groupedData objectForKey:key] filteredArrayUsingPredicate:predicate];
                        
                        ((models_User *)[result objectAtIndex:0]).isFollowed = @"true";
                    }   
                }
            }
        }
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_isSearching) {
        
        return @"";
    } else {
     
        if (_sortedKeys != nil && section < [_sortedKeys count]) {
         
            NSString *key = [_sortedKeys objectAtIndex:section];
            
            if (key != nil) {
                
                return [NSString stringWithFormat:@"%@", key];
            } else {
                
                return @"";
            }
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
        u = (models_User *)[self getObjForSection:indexPath.section andRow:indexPath.row];
    }
    
    if (u != nil) {
        
     
        [[NSBundle mainBundle] loadNibNamed:@"views_friends_item_All" owner:self options:nil];
        
        // image
        if ([_imagesCache.allKeys containsObject:u.picture]) {
            
            _itemImage.image = (UIImage *)[_imagesCache objectForKey:u.picture];
        } else {
            
            _itemImage.imageURL = [NSURL URLWithString:u.picture];
            _itemImage.delegate = self;
        }
        _itemImage.clipsToBounds = YES;
        _itemImage.contentMode = UIViewContentModeScaleAspectFill;
        
        _itemTitle.text = [NSString stringWithFormat:@"%@ %@", u.firstName, u.lastName];
        
        //if ([u.isFollowed isEqualToString:@"true"]) {
        
        if ([self contains:_following user:u]) {
            
            [_switch setOn:YES];
        } else {
            [_switch setOn:NO];        
        }
        
        [cell.contentView addSubview:_item];
    }
    
    u = nil;
    
    return cell;
}

- (BOOL)contains:(NSMutableDictionary *)dic user:(models_User *)u
{
    for (NSString *key in [dic allKeys]) {
        
        for (models_User *crtU in (NSArray *)[dic objectForKey:key]) {
            
            if ([crtU.uid isEqualToString:u.uid]) {
                
                return true;
            }
        }
    }
    
    return false;
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
    NSIndexPath *path = nil;
    models_User *friend = nil;
    
    if (_isSearching) {
        
        path = [self.searchDisplayController.searchResultsTableView indexPathForCell:cell];
        friend = [_filteredData objectAtIndex:path.row];
        
    } else {
        
        path = [self.tableView indexPathForCell:cell];
        friend = [self getObjForSection:path.section andRow:path.row];
    }
    
    [params setValue:friend.uid forKey:@"friendID"];
    
    UISwitch *s = (UISwitch *)sender;
    
    if (!s.isOn) {
        
        [_user unfollow:params success:@selector(onFollowSuccess:) failure:@selector(onFollowFailure:) sender:sender];

        models_User *userToRemove = nil;
        
        // update _following
        for (NSString *key in [_following allKeys]) {
            
            for (models_User *u in (NSArray *)[_following objectForKey:key]) {
                
                if ([u.uid isEqualToString:friend.uid]) {
                    
                    userToRemove = u;
                    break;
                }
            }
            
            if (userToRemove != nil) {
                
                NSMutableArray *array = (NSMutableArray *)[_following objectForKey:key];
                
                if (array != nil) {
                    
                    [array removeObject:userToRemove];
                    
                    if (key != nil) {
                     
                        [_following setObject:array forKey:key]; 
                    }
                }
                
                break;
            }
        }
        
        // update _data
        
        
    } else {
        
        [_user follow:params success:@selector(onFollowSuccess:) failure:@selector(onFollowFailure:) sender:sender];

        NSMutableArray *a = [[NSMutableArray alloc] init];
        NSString *key = [[friend.lastName uppercaseString] substringToIndex:1];
        
        if (key != nil) {
         
            if (_following == nil) {
                
                _following = [[NSMutableDictionary alloc] init];
            } else {
                
                if ((NSMutableArray *)[_following objectForKey:key] != nil) {
                    
                    a = (NSMutableArray *)[_following objectForKey:key];
                }
            }
            
            if (friend != nil && a != nil && key != nil) {
                
                [a addObject:friend];
                [_following setObject:a forKey:key];   
            }
        }
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

- (void)openDrawer
{
//    if (_following == nil) {
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFollowings:) name:@"followingLoaded" object:nil];
//    }
}

- (void)closeDrawer
{
    if (_isDirty) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadFollowing" object:nil];
    }
    
    _isDirty = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openDrawer) name:ECSlidingViewUnderRightWillAppear object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeDrawer) name:ECSlidingViewTopDidReset object:nil];

    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    self.peekLeftAmount = 40.0f;
    [self.slidingViewController setAnchorLeftPeekAmount:self.peekLeftAmount];
    self.slidingViewController.underRightWidthLayout = ECVariableRevealWidth;
    
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"grayBG"]]];
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
            
            [_ctrl reloadTableViewDataSource:NO];
        } else {
         
            [_ctrl.tableView reloadData];
        }
    }
    
    return _ctrl;
}

+ (void)release
{
    [models_User release];
    _ctrl = nil;
}

@end
