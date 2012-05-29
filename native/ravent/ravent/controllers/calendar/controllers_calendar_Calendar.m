//
//  controllers_calendar_Calendar.m
//  ravent
//
//  Created by florian haftman on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_calendar_Calendar.h"
#import "dataSource.h"
#import "controllers_events_Details.h"

@implementation controllers_calendar_Calendar

static customNavigationController *_ctrl;
@synthesize kal = _kal;

- (id)init
{
    self = [super init];
    if (self != nil) {
        
        _kal = [[KalViewController alloc] init];
        _datasource = [[dataSource alloc] init];
        
        _kal.delegate = self;
        _kal.dataSource = _datasource;
        
        _kal.view.frame = CGRectMake(0, 0, 320, 460);
        
        [self addChildViewController:_kal];
        [self.view addSubview:_kal.view];
    }
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    models_Event *event = [(dataSource *)_kal.dataSource eventAtIndexPath:indexPath];
    
    controllers_events_Details *details = [[controllers_events_Details alloc] initWithReloadEvent:[event copy]]; 
    
    UIImage *backi = [UIImage imageNamed:@"backButton"];
    
    UIButton *backb = [UIButton buttonWithType:UIButtonTypeCustom];
    [backb addTarget:details action:@selector(cancellAllRequests:) forControlEvents:UIControlEventTouchUpInside];
    [backb setImage:backi forState:UIControlStateNormal];
    [backb setFrame:CGRectMake(0, 0, backi.size.width, backi.size.height)];
    
    //    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backb];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target:details action:@selector(cancellAllRequests)];
    UIViewController *rootController = self;
    
    while (![rootController.parentViewController isKindOfClass:[UINavigationController class]]) {
        
        rootController = rootController.parentViewController;
    }
    
    [rootController.navigationItem setBackBarButtonItem: backButton];
    [self.navigationController pushViewController:details animated:YES];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *menui = [UIImage imageNamed:@"menuButton"];
    
    UIButton *menub = [UIButton buttonWithType:UIButtonTypeCustom];
    [menub addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    [menub setImage:menui forState:UIControlStateNormal];
    [menub setFrame:CGRectMake(0, 0, menui.size.width, menui.size.height)];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:menub];
    self.navigationItem.leftBarButtonItem = menuButton;    
    
    self.title = @"Ravent";
    
}

- (void)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
    // You just need to set the opacity, radius, and color.
    self.parentViewController.view.layer.shadowOpacity = 0.75f;
    self.parentViewController.view.layer.shadowRadius = 10.0f;
    self.parentViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[controllers_SlidingMenu class]]) {
        self.slidingViewController.underLeftViewController  = [controllers_SlidingMenu instance];
    }
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    ((dataSource *)_kal.dataSource).dataReady = NO;
    [_kal reloadData];
}

+ (customNavigationController *)instance
{
    if (_ctrl == nil) {
        
        controllers_calendar_Calendar *cal = [[controllers_calendar_Calendar alloc] init];
        
        _ctrl = [[customNavigationController alloc] initWithRootViewController:cal];;
    }
    
    return _ctrl;
}

@end
