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
    [_spinner stopAnimating];
    
    UIView *v = nil;
    
    for (int i = 0; i < [[_footer subviews] count]; i++) {
        
        v = [[_footer subviews] objectAtIndex:i];
        
        if ([v isKindOfClass:[UIActivityIndicatorView class]]) {
            
            [v setHidden:YES];
            
            [((UIActivityIndicatorView *)v) stopAnimating];
        }
        
        if ([v isKindOfClass:[UILabel class]]) {
            
            UILabel *l = (UILabel *)v;
            if ([l.text isEqualToString:@"Loading"]) {
                
                [v setHidden:YES];   
            }
        }
    }
    
    
    
    [super onLoadData:objects withSuccess:^ {
        
        if (objects != nil) {
         
            _data = [[NSMutableArray alloc] initWithArray:objects]; 
        }
    }];
    
    if (objects == nil || [objects count] == 0) {
        
        _footerLabel.text = @"no friend invited";
    }
}

- (models_User *)getUserForRow:(NSInteger)row
{
    if (_data != nil && row < [_data count]) {
        
        return [_data objectAtIndex:row];
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    [[NSBundle mainBundle] loadNibNamed:@"views_friends_item_Invited" owner:self options:nil];
    
    models_User *u = [self getUserForRow:indexPath.row];
    
    if (u != nil) {
     
        
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
        _itemSubTitle.text = (u.rsvpStatus != nil && ![u.rsvpStatus isEqualToString:@""]) ? u.rsvpStatus : @"not replied";

        
        [cell.contentView addSubview:_item];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    models_User *user = [self getUserForRow:indexPath.row];
    
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
        
        [self performSelector:@selector(fadeInToolbar) withObject:nil afterDelay:0.3];
    }
}

- (void)fadeInToolbar
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [self.navigationController.navigationBar setAlpha:1];
    [UIView commitAnimations];
}

- (void)onBackTap
{
    [self.navigationController popViewControllerAnimated:YES];
    
    [self performSelector:@selector(detailsDealloc) withObject:nil afterDelay:0.5];
}

- (void)detailsDealloc
{
    [_details mydealloc];
    _details = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_spinner startAnimating];
}

- (void)mydealloc
{
    [_user mydealloc];
    
    if (_details) {
        
        [_details mydealloc];
        _details = nil;
    }
    
    _noFriendLabel = nil;
    _footer = nil;
    
    self.tableView.tableFooterView = nil;
    
    [super mydealloc];
}

@end
