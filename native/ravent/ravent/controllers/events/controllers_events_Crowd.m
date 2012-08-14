//
//  controllers_events_CrowdViewController.m
//  ravent
//
//  Created by flo on 8/13/12.
//
//

#import "controllers_events_Crowd.h"

@interface controllers_events_Crowd ()

@end

@implementation controllers_events_Crowd

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithEid:(NSString *)eid
{
    self = [super init];
    
    if (self) {
        
        _eid = eid;
        _user = [[models_User crtUser] copy];
        
        _user.delegate = self;
        _user.callback = @selector(onLoadData:);
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIImage *donei = [UIImage imageNamed:@"doneButton"];
    UIButton *doneb = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneb addTarget:self action:@selector(hideAllModal) forControlEvents:UIControlEventTouchUpInside];
    [doneb setImage:donei forState:UIControlStateNormal];
    [doneb setFrame:CGRectMake(0, 0, donei.size.width, donei.size.height)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithCustomView:doneb];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    [self loadData];
    
    // shadows
    UIImageView *ivtop = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    [ivtop setImage:[UIImage imageNamed:@"shadowTop"]];
    [self.parentViewController.view addSubview:ivtop];
}

- (void)loadData
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:_user.accessToken forKey:@"access_token"];
    [params setValue:_eid forKey:@"eid"];
    [_user loadInvitedWithParams:params];
}

- (void)onLoadData:(NSArray *)objects
{
    [super onLoadData:objects withSuccess:^ {
        
        if (objects != nil) {
            
            _data = [[NSMutableArray alloc] initWithArray:objects];
            _groupedUsers = [self getGroupedUsers:_data];
            self.tableView.tableFooterView = nil;
        }
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_groupedUsers count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 106;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSBundle mainBundle] loadNibNamed:@"views_events_item_Crowd" owner:self options:nil];
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    NSMutableArray *row = [_groupedUsers objectAtIndex:indexPath.row];
    NSArray *imgs = [NSArray arrayWithObjects:_img1, _img2, _img3, nil];
    
    for (int i = 0; i < [imgs count]; i++) {
        
        if (i < [row count]) {
         
            models_User *u = [row objectAtIndex:i];
            JBAsyncImageView *img = [imgs objectAtIndex:i];
            
            // image
            if ([_imagesCache.allKeys containsObject:u.picture]) {
                
                img.image = (UIImage *)[_imagesCache objectForKey:u.picture];
            } else {
                
                img.imageURL = [NSURL URLWithString:u.picture];
                img.delegate = self;
            }
            img.clipsToBounds = YES;
            img.contentMode = UIViewContentModeScaleAspectFill;
        }
    }
    
    [cell.contentView addSubview:_item];
    
    return cell;
}

- (NSMutableArray *)getGroupedUsers:(NSMutableArray *)data
{
    NSMutableArray *res = [[NSMutableArray alloc] init];
    
    if (data != nil) {
        
        int i = 0;
        
        while (i < [_data count]) {
            
            NSMutableArray *row = [[NSMutableArray alloc] init];
            
            
            [row addObject:[_data objectAtIndex:i]];
            i += 1;
            if (i < [_data count]) {
                
                [row addObject:[_data objectAtIndex:i]];
                i += 1;
                if (i < [_data count]) {
                    
                    [row addObject:[_data objectAtIndex:i]];
                    i += 1;
                }
            }
            
            [res addObject:row];
        }
    }
    
    return res;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)hideAllModal
{

    _groupedUsers = nil;
    _img1 = nil;
    _img2 = nil;
    _img3 = nil;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
    _groupedUsers = nil;
    _img1 = nil;
    _img2 = nil;
    _img3 = nil;
}

@end
