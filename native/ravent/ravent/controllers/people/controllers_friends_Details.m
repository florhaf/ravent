//
//  controllers_friends_Details.m
//  ravent
//
//  Created by florian haftman on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_friends_Details.h"
#import "JBAsyncImageView.h"

@implementation controllers_friends_Details

- (void)loadData
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:_user.uid forKey:@"userID"];
    [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
    [params setValue:[models_User crtUser].latitude forKey:@"latitude"];
    [params setValue:[models_User crtUser].longitude forKey:@"longitude"];
    [params setValue:[models_User crtUser].timeZone forKey:@"timezone_offset"];
    
    [_event loadEventsWithParams:params];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSBundle mainBundle] loadNibNamed:@"views_friends_Details" owner:self options:nil];
    
    _userImage.imageURL = [NSURL URLWithString:_user.picture];
    _nameLabel.text = [NSString stringWithFormat:@"%@ %@", _user.firstName, _user.lastName];
    
    if (_user.nbOfEvents != nil && ![_user.nbOfEvents isEqualToString:@""]) {
     
        _eventsLabel.text = _user.nbOfEvents;
        _followersLabel.text = _user.nbOfFollowers;
        _followingLabel.text = _user.nbOfFollowing;
    } else {
        
        _user.delegate = self;
        _user.callback = @selector(onUserLoad:);
        [_user loadUser];
    }
        
    _fbButton.titleLabel.text = [NSString stringWithFormat:@"Ask where %@ is going", _user.firstName];

    self.tableView.tableHeaderView = _detailsView;
    
    UILabel *labelLoading = [[UILabel alloc] init];
    labelLoading.text = @"Loading";
    labelLoading.frame = CGRectMake(0, 0, 320, 50);
    labelLoading.textAlignment= UITextAlignmentCenter;
    
    UIActivityIndicatorView *myIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    myIndicator.center = CGPointMake(110, 27);
    
    [myIndicator startAnimating];
    
    UIView *footer = [[UIView alloc] init];
    [footer addSubview:labelLoading];
    [footer addSubview:myIndicator];
    
    footer.frame = CGRectMake(0, 0, 320, 160);
    
    self.tableView.tableFooterView = footer;
}

- (void)onUserLoad:(NSArray *)objects
{
    if (objects == nil || [objects count] == 0) {
        
        _eventsLabel.text = @"?";
        _followersLabel.text = @"?";
        _followingLabel.text = @"?";
        return;
    }
    
    models_User *u = (models_User *)[objects objectAtIndex:0];
    
    if ([u isKindOfClass:[NSError class]]) {
        
        _eventsLabel.text = @"?";
        _followersLabel.text = @"?";
        _followingLabel.text = @"?";
        return;
    }

    _eventsLabel.text = u.nbOfEvents;
    _followersLabel.text = u.nbOfFollowers;
    _followingLabel.text = u.nbOfFollowing;
}

@end
