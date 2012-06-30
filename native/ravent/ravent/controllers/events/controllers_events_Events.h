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

#import <QuartzCore/QuartzCore.h>
#import "ECSlidingViewController.h"
#import "controllers_SlidingMenu.h"
#import "customNavigationController.h"

@interface controllers_events_Events : UIViewController {
    
    
    controllers_events_List_p2p *_listController;
    controllers_events_Map_p2p *_mapController;
    
    IBOutlet UIToolbar *_toolbar;
    IBOutlet UISegmentedControl *_seg;
    
    IBOutlet UIView *_optionsView;
    IBOutlet UIButton *_optionsButton;
    
    IBOutlet UIStepper *_radiusStepper;
    IBOutlet UIStepper *_windowStepper;
    
    IBOutlet UILabel *_labelRadiusValue;
    IBOutlet UILabel *_labelWindowValue;
    
    IBOutlet UIButton *_partyButton;
    IBOutlet UIButton *_chillbutton;
    IBOutlet UIButton *_artButton;
    IBOutlet UIButton *_miscButton;
    
    models_User *_user;
    
    BOOL _isDirty;
}

- (IBAction)onValueChanged:(id)sender;
- (IBAction)onSO_Tap:(id)sender;
- (IBAction)stepperWindowPressed:(UIStepper *)sender;
- (IBAction)stepperRadiusPressed:(UIStepper *)sender;
- (IBAction)onPartyButton_Tap:(id)sender;
- (IBAction)onChillButton_Tap:(id)sender;
- (IBAction)onArtButton_Tap:(id)sender;
- (IBAction)onMiscButton_Tap:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forUser:(models_User *)user;

- (void)revealMenu:(id)sender;
- (void)revealMap:(id)sender;

+ (customNavigationController *)instance;
+ (void)release;

@end
