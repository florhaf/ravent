/**
   Copyright 2011 Atlassian Software

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
**/
#import "JMCIssuesViewController.h"
#import "JMCIssuePreviewCell.h"
#import "JMCIssueViewController.h"
#import "JMC.h"
#import "UILabel+JMCVerticalAlign.h"
#import "JMCMacros.h"
#import "JMCRequestQueue.h"
#import "controllers_SlidingMenu.h"


static NSString *cellId = @"CommentCell";

@implementation JMCIssuesViewController

@synthesize issueStore = _issueStore;

static customNavigationController *_ctrl;

- (id)initWithStyle:(UITableViewStyle)style {

    self = [super initWithStyle:style];
    if (self) {
        
        self.title = JMCLocalizedString(@"Your Feedback", @"Title of list of previous messages");
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:kJMCIssueUpdated object:nil];
    }
    return self;
}

- (void)compose:(UIBarItem *)arg
{

        [self presentModalViewController:[[JMC sharedInstance] feedbackViewControllerWithMode:JMCViewControllerModeDefault] animated:YES];
}

- (void)cancel:(UIBarItem *)arg
{
    UIViewController *presentingViewController = nil;
    if ([self.navigationController respondsToSelector:@selector(presentingViewController)]) {
        presentingViewController = [self.navigationController presentingViewController];
    }
    else {
        presentingViewController = self.navigationController.parentViewController;
    }
    
    if (presentingViewController) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
        CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;
        
        [UIView animateWithDuration:0.4 animations:^{
            CGRect frame = self.navigationController.view.frame;
            CGRect toFrame = CGRectMake(0, screenSize.height + statusBarFrame.size.height, frame.size.width, frame.size.height);
            [self.navigationController.view setFrame:toFrame];
            
        } completion:^(BOOL finished) {

        }];
    }

}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIImage *menubg = [[UIImage imageNamed:@"navBarBG"] autorelease];
    UIImage *menui = [[UIImage imageNamed:@"navBarMenu"] autorelease];
    
    UIButton *menub = [[UIButton buttonWithType:UIButtonTypeCustom] autorelease];
    [menub addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    [menub setImage:menui forState:UIControlStateNormal];
    [menub setBackgroundImage:menubg forState:UIControlStateNormal];
    [menub setFrame:CGRectMake(0, 0, 40, 29)];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:menub];
    self.navigationItem.leftBarButtonItem = menuButton;
    
    UIImage *posti = [[UIImage imageNamed:@"postButton"] autorelease];
    UIButton *postb = [[UIButton buttonWithType:UIButtonTypeCustom] autorelease];
    [postb addTarget:self action:@selector(compose:) forControlEvents:UIControlEventTouchUpInside];
    [postb setImage:posti forState:UIControlStateNormal];
    [postb setFrame:CGRectMake(0, 0, posti.size.width, posti.size.height)];
    UIBarButtonItem *postButton = [[[UIBarButtonItem alloc] initWithCustomView:postb] autorelease];
    self.navigationItem.rightBarButtonItem = postButton;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[JMCRequestQueue sharedInstance] flushQueue];
    [super viewWillAppear:animated];
  
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[controllers_SlidingMenu class]]) {
        self.slidingViewController.underLeftViewController  = [controllers_SlidingMenu instance];
    }
    
    if (self.slidingViewController.underRightViewController != nil) {
        self.slidingViewController.underRightViewController = nil;
    }
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.issueStore count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    JMCIssuePreviewCell *cell = (JMCIssuePreviewCell *) [tableView dequeueReusableCellWithIdentifier:cellId];

    if (cell == NULL) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"JMCIssuePreviewCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }

    JMCIssue *issue = [self.issueStore newIssueAtIndex:indexPath.row];
        
    JMCComment *latestComment = [issue latestComment];
    cell.detailsLabel.text = latestComment != nil ? latestComment.body : issue.description;
    [cell.detailsLabel jmc_alignTop];
    cell.titleLabel.text = issue.summary;
    NSDate *date = latestComment.date != nil ? latestComment.date : issue.dateUpdated;
    cell.dateLabel.text = [_dateFormatter stringFromDate:date];
    cell.statusLabel.hidden = !issue.hasUpdates;
    JMCSentStatus sentStatus = [[JMCRequestQueue sharedInstance] requestStatusFor:issue.requestId];
    cell.sentStatusLabel.hidden = sentStatus != JMCSentStatusPermError; // TODO: after n-attempts are reached, set status to PermError.

    [issue release];
    
    NSLog(@"%d", indexPath.row);
    
    return cell;
}

-(void) refreshTable {
    [self.tableView reloadData];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    JMCIssue *issue = [self.issueStore newIssueAtIndex:indexPath.row];
    JMCSentStatus sentStatus = [[JMCRequestQueue sharedInstance] requestStatusFor:issue.requestId];

    if (sentStatus != JMCSentStatusSuccess) {
        
        NSString* title = (sentStatus == JMCSentStatusPermError) ?
        JMCLocalizedString(@"JMCRequestPermErrorTitle", @"Alert title when message has not been sent to JIRA after N attempts.") :
        JMCLocalizedString(@"JMCRequestPendingTitle", @"Alert title when message not yet arrived in JIRA");
        NSString* message = (sentStatus == JMCSentStatusPermError) ?
        JMCLocalizedString(@"JMCRequestPermErrorMessage", @"Alert when create issue request not successful after N attempts."):
        JMCLocalizedString(@"JMCRequestPendingMessage", @"Alert when create issue request not yet successful");
        UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: title
                                       message: message
                                      delegate: nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
            [alert show];
            [alert release];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; 

    } else {
    
        issue.comments = [self.issueStore loadCommentsFor:issue];
        JMCIssueViewController *detailViewController = [[JMCIssueViewController alloc] initWithNibName:@"JMCIssueViewController" bundle:nil];
        detailViewController.issue = issue;
        
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
        
        [self.issueStore markAsRead:issue];
        [tableView reloadData]; // redraw the table.
    }
    [issue release];
}
#pragma mark end

- (void)dealloc {
    //if (self) {
        self.issueStore = nil;
        [_dateFormatter release];
        _dateFormatter = nil;
    //make the app crash at logout...
        [super dealloc];
    //}
}

+ (customNavigationController *)instance
{
    if (_ctrl == nil) {
        
        JMCIssuesViewController *issues = [[[JMCIssuesViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        [issues setIssueStore:[JMCIssueStore instance]];
        _ctrl = [[customNavigationController alloc] initWithRootViewController:issues];
    }
    
    return _ctrl;
}

+ (void)release
{
    _ctrl = nil;
}

@end
