//
//  controllers_friends_Following.m
//  ravent
//
//  Created by florian haftman on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_friends_Following.h"

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataWithSpinner) name:@"reloadFollowing" object:nil];

        [self loadDataWithSpinner];
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
    
    _url = [@"followings" appendQueryParams:params];
    Action *upadteLoadingMessageAction = [[Action alloc] initWithDelegate:self andSelector:@selector(updateLoadingMessageWith:)];
    [[ActionDispatcher instance] add:upadteLoadingMessageAction named:_url];
    
    [_user loadFollowingsWithParams:params];
    
    [[ActionDispatcher instance]execute:@"reloadCurrentUser"];
}

- (void)onLoadFollowings:(NSArray *)objects
{   
    if (objects == nil || [objects count] == 0) {
        
        if (_isFollowing) {
            
            [[NSBundle mainBundle]loadNibNamed:@"views_Empty_Following" owner:self options:nil];
            
        } else {
         
            [[NSBundle mainBundle]loadNibNamed:@"views_Empty_Generic" owner:self options:nil];
            ((UILabel *)[_emptyMessageView.subviews objectAtIndex:0]).text = @"no follower yet";
        }
    }
    
    
    [self onLoadData:objects withSuccess:^ {
        
        if (objects != nil) {
            
            if ([objects count] == 0) {
            
                _showEmptyMessage = YES;
                _emptyView.frame = CGRectMake(0, 0, 320, 312);
                _emptyImageView.frame = CGRectMake(_emptyImageView.frame.origin.x, _emptyImageView.frame.origin.y + 40, _emptyImageView.frame.size.width, _emptyImageView.frame.size.height);
            } else {
                
                _data = objects;
                _groupedData = [models_User getGroupedData:_data];
                _sortedKeys = [[_groupedData allKeys] sortedArrayUsingSelector:@selector(compare:)];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"followingLoaded" object:nil userInfo:_groupedData];
        }
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
    
    models_User *u = (models_User *)[self getObjForSection:indexPath.section andRow:indexPath.row];
    
    if (u != nil) {
     
        [[NSBundle mainBundle] loadNibNamed:@"views_friends_item_Following" owner:self options:nil];
        
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
        
        _followersLabel.text = u.nbOfFollowers;
        _followingLabel.text = u.nbOfFollowing;
        _eventsLabel.text = u.nbOfEvents;
        
        [cell.contentView addSubview:_item];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    models_User *user = (models_User *)[self getObjForSection:indexPath.section andRow:indexPath.row];
    
    if (user != nil) {
     
        _details = [[controllers_friends_Details alloc] initWithUser:[user copy]];
        
        UIImage *backi = [UIImage imageNamed:@"backButton"];
        
        UIButton *backb = [UIButton buttonWithType:UIButtonTypeCustom];
        [backb addTarget:self action:@selector(onBackTap) forControlEvents:UIControlEventTouchUpInside];
        [backb setImage:backi forState:UIControlStateNormal];
        [backb setFrame:CGRectMake(0, 0, backi.size.width, backi.size.height)];
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backb];
        
        UIViewController *rootController = self;
        
        while (![rootController.parentViewController isKindOfClass:[UINavigationController class]]) {
            
            rootController = rootController.parentViewController;
        }
        
        [rootController.navigationItem hidesBackButton];
        [_details.navigationItem setLeftBarButtonItem:backButton];
        [self.navigationController pushViewController:_details animated:YES];
    }
}

- (void)onBackTap
{
    [(controllers_friends_Details *)_details cancelAllRequests];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self trackPageView:@"friends_following" forEvent:nil];
}

@end
