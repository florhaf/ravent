//
//  controllers_friends_share.h
//  ravent
//
//  Created by florian haftman on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UITableViewSearchable.h"

@interface controllers_friends_share : UITableViewSearchable {
    
    NSArray *_invited;
    
    IBOutlet UIButton *_inviteButton;
    IBOutlet UIActivityIndicatorView *_indic;
    
    NSMutableArray *_friends;
}

- (id)initWithUser:(models_User *)user invited:(NSArray *)invited;
- (void)loadData:(BOOL)force;
- (void)onLoadAll:(NSArray *)objects;

- (IBAction)onShareTap:(id)sender;

@end
