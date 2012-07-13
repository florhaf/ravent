//
//  controllers_TakeTheTour.h
//  ravent
//
//  Created by florian haftman on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface controllers_TakeTheTour : UIViewController {
    
    IBOutlet UIView *_container;
    IBOutlet UIButton *_next;
}

@property (nonatomic, retain) UIView *container;
@property (nonatomic, retain) UIButton *next;

- (IBAction)next:(id)sender;
- (IBAction)no:(id)sender;

+ (controllers_TakeTheTour *)instance;


@end
