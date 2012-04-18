//
//  controllers_events_Events.h
//  ravent
//
//  Created by florian haftman on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "controllers_events_List_p2p.h"
#import "controllers_events_Map_p2p.h"
#import "models_User.h"



@interface controllers_events_Events : UIViewController {
    
    
    controllers_events_List_p2p *_listController;
    controllers_events_Map_p2p *_mapController;
    models_User *_user;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forUser:(models_User *)user;
- (void)flipView;

@end
