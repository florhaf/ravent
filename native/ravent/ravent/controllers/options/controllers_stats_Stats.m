//
//  controllers_stats_Stats.m
//  ravent
//
//  Created by florian haftman on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_stats_Stats.h"

@implementation controllers_stats_Stats

static controllers_stats_Stats *_ctrl;

- (void)loadData
{
    
}

+ (controllers_stats_Stats *)instance
{
    if (_ctrl == nil) {
        
        _ctrl = [[controllers_stats_Stats alloc] init];
    }
    
    return _ctrl;
}

@end
