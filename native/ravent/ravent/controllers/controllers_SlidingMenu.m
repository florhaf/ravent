//
//  controllers_SlidingMenu.m
//  ravent
//
//  Created by florian haftman on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_SlidingMenu.h"
#import "controllers_events_Events.h"
#import "controllers_friends_People.h"
#import "controllers_calendar_Calendar.h"
#import "controllers_stats_Stats.h"
#import "customNavigationController.h"
#import "controllers_Login.h"
#import "JMC.h"

@implementation controllers_SlidingMenu

@synthesize menuItems;

static controllers_SlidingMenu *_ctrl;

- (id)init
{
    self = [super init];
    
    if (self) {
        
        self.menuItems = [NSArray arrayWithObjects:@"Events", @"People", @"Calendar", @"Stats", @"Feedback", nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroundDark"]];
    
    UITableView *menuTable = [[UITableView alloc] init];
    menuTable.delegate = self;
    menuTable.dataSource = self;
    menuTable.frame = CGRectMake(0, 0, 280, 640);
    menuTable.backgroundColor = [UIColor clearColor];
    menuTable.opaque = YES;
    
    [self.view addSubview:bg];
    [self.view addSubview:menuTable];
    
    [menuTable setSeparatorColor:[UIColor darkGrayColor]];
    
    UILabel *signOutLabel = [[UILabel alloc] init];
    signOutLabel.text = @"Sign out";
    signOutLabel.textColor = [UIColor grayColor];
    signOutLabel.frame = CGRectMake(10, 0, 280, 44);
    signOutLabel.backgroundColor = [UIColor clearColor];
    signOutLabel.opaque = YES;
    signOutLabel.shadowColor = [UIColor blackColor];
    signOutLabel.shadowOffset = CGSizeMake(0, 1);
    [signOutLabel setFont:[UIFont boldSystemFontOfSize:17]];
    
    // make the sign out clickable
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = signOutLabel.frame;
    [btn addTarget:[controllers_Login instance] action:@selector(onLogoutButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [menuTable.tableFooterView addSubview:btn];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 44)];
    [footer addSubview:signOutLabel];
    [footer addSubview:btn];
    
    menuTable.tableFooterView = footer;
    
    [self.slidingViewController setAnchorRightRevealAmount:280.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"MenuItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.shadowColor = [UIColor blackColor];
    cell.textLabel.shadowOffset = CGSizeMake(0, 1);
    cell.textLabel.text = [self.menuItems objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    
        UIImageView *discl = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]];
        cell.accessoryView = discl;
        cell.accessoryView.frame = CGRectMake(discl.frame.origin.x - 50, discl.frame.origin.y, discl.frame.size.width, discl.frame.size.height);
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self.menuItems objectAtIndex:indexPath.row];
    
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    
    if ([identifier isEqualToString:@"Events"]) {
        
        newTopViewController = [controllers_events_Events instance];
    } else {
        
        if ([identifier isEqualToString:@"People"]) {
            
            newTopViewController = [controllers_friends_People instance];
        } else {
            
            if ([identifier isEqualToString:@"Calendar"]) {
                
                newTopViewController = [controllers_calendar_Calendar instance];
            } else {
                
                if ([identifier isEqualToString:@"Stats"]) {
                
                    newTopViewController = [controllers_stats_Stats instance];
                } else {
                    
                    newTopViewController = [[JMC sharedInstance] issuesViewController];
                }
            }
        }
    }
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}

+ (controllers_SlidingMenu *)instance
{
    if (_ctrl == nil) {
        
        _ctrl = [[controllers_SlidingMenu alloc] init];
    }
    
    return _ctrl;
}


@end
