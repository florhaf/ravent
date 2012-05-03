//
//  UITableViewFriends.m
//  ravent
//
//  Created by florian haftman on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITableViewFriends.h"
#import "controllers_friends_Details.h"

@implementation UITableViewFriends

- (id)initWithEvent:(models_Event *)event
{
    self = [super init];
    
    if (self != nil) {
        
        [[NSBundle mainBundle] loadNibNamed:@"views_friends_item_Invited" owner:self options:nil];

        _itemSize = CGSizeMake(_item.frame.size.width, _item.frame.size.height);
        _titleSize = CGSizeMake(_itemTitle.frame.size.width, _itemTitle.frame.size.height);
        _subTitleSize = CGSizeMake(_itemSubTitle.frame.size.width, _itemSubTitle.frame.size.height);
        
        _event = event;
        _user = [[models_User crtUser] copy];
        _user.delegate = self;
        _user.callback = @selector(onLoadInvited:);
        
        [self loadData];
    }
    
    return self;
}

- (void)loadData
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:_user.accessToken forKey:@"access_token"];
    [params setValue:_user.uid forKey:@"userID"];
    [params setValue:_event.eid forKey:@"eid"];
    [_user loadInvitedWithParams:params];
}

- (void)onLoadInvited:(NSArray *)objects
{
    [super onLoadData:objects withSuccess:^ {
        
        _data = [[NSMutableArray alloc] initWithArray:objects]; 
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [[NSBundle mainBundle] loadNibNamed:@"views_friends_item_Invited" owner:self options:nil];
    
    models_User *u = [_data objectAtIndex:indexPath.row];
    
    _itemTitle.text = [NSString stringWithFormat:@"%@ %@", u.firstName, u.lastName];
    _itemSubTitle.text = u.rsvpStatus;
    _itemImage.imageURL = [NSURL URLWithString:u.picture];
    
    [cell.contentView addSubview:_item];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    models_User *user = [_data objectAtIndex:indexPath.row];
    
    controllers_friends_Details *details = [[controllers_friends_Details alloc] initWithUser:[user copy]];
    
    UIImage *menui = [UIImage imageNamed:@"backButton"];
    
    UIButton *menub = [UIButton buttonWithType:UIButtonTypeCustom];
    [menub addTarget:details action:@selector(cancellAllRequests:) forControlEvents:UIControlEventTouchUpInside];
    [menub setImage:menui forState:UIControlStateNormal];
    [menub setFrame:CGRectMake(0, 0, menui.size.width, menui.size.height)];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:menub];
    
    //    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target:details action:@selector(cancellAllRequests)];
    
    UIViewController *rootController = self;
    while (![rootController.parentViewController isKindOfClass:[UINavigationController class]]) {
        rootController = rootController.parentViewController;
    }
    [rootController.navigationItem setBackBarButtonItem: backButton];
    [self.navigationController pushViewController:details animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"Loading";
    label.frame = CGRectMake(0, 0, 320, 50);
    label.textAlignment= UITextAlignmentCenter;
    
    UIActivityIndicatorView *myIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    myIndicator.center = CGPointMake(110, 27);
    
    [myIndicator startAnimating];
    
    UIView *footer = [[UIView alloc] init];
    [footer addSubview:label];
    [footer addSubview:myIndicator];
    footer.backgroundColor = [UIColor clearColor];
    
    footer.frame = CGRectMake(0, 0, 320, 160);
    
    self.tableView.tableFooterView = footer;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

@end
