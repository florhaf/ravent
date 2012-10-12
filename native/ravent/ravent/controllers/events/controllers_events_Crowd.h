//
//  controllers_events_CrowdViewController.h
//  ravent
//
//  Created by flo on 8/13/12.
//
//

#import "UITableViewReloadable.h"

@interface controllers_events_Crowd : UITableViewReloadable
{
    NSString *_eid;
    
    NSMutableArray *_groupedUsers;
    
    IBOutlet JBAsyncImageView *_img1;
    IBOutlet JBAsyncImageView *_img2;
    IBOutlet JBAsyncImageView *_img3;
}


- (id)initWithEid:(NSString *)eid;
- (void)mydealloc;
- (NSMutableArray *)getGroupedUsers:(NSArray *)data;

@end
