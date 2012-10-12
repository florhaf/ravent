//
//  controllers_events_Specials.m
//  ravent
//
//  Created by florian haftman on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_events_Specials.h"
#import "models_User.h"
#import "GANTracker.h"

@interface controllers_events_Specials ()

@end

@implementation controllers_events_Specials

- (void)trackPageView:(NSString *)named forEvent:(NSString *)eid
{
    NSError *error;
    
    if (eid != nil) {
        
        [[GANTracker sharedTracker] setCustomVariableAtIndex:1
                                                        name:@"eid"
                                                       value:eid
                                                   withError:&error];
    }
    
    [[GANTracker sharedTracker] setCustomVariableAtIndex:2
                                                    name:@"uid"
                                                   value:[models_User crtUser].uid
                                               withError:&error];
    
    [[GANTracker sharedTracker] setCustomVariableAtIndex:3
                                                    name:@"app_version"
                                                   value:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
                                               withError:&error];
    
    [[GANTracker sharedTracker] trackPageview:named
                                    withError:&error];
}

- (id)initWithEvent:(models_Event *)event
{
    self = [super initWithNibName:@"views_events_Specials" bundle:nil];
    if (self) {

        _event = event;
        
        self.title = @"Gemster";
        
        [self trackPageView:@"events_details_specials" forEvent:event.eid];
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _tickerItems = [[NSArray alloc] initWithObjects:_event.name, nil];
    [_ticker reloadData];
    
    _labelLocation.text = _event.location;
    _labelAddress.text = _event.address;
    _labelOfferTitle.text = _event.offerTitle;
    _labelOfferDescription.text = _event.offerDescription;
    
    if (_event.isGemDropped) {
        
        _labelRule.text = @"Gem Dropped !";
        _lockImage.image = [UIImage imageNamed:@"unlocked"];
    } else {
        
        _labelRule.text = @"Drop a gem to unlock this Goodies";
    }
    
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

- (void)cancelAllRequests
{
    
}

#pragma mark - Ticker delegate

- (UIColor*) backgroundColorForTickerView:(MKTickerView *)vertMenu
{
    return [UIColor clearColor];
}

- (int) numberOfItemsForTickerView:(MKTickerView *)tabView
{
    return [_tickerItems count];
}

- (NSString*) tickerView:(MKTickerView *)tickerView titleForItemAtIndex:(NSUInteger)index
{
    return [_tickerItems objectAtIndex:index];
}

- (NSString*) tickerView:(MKTickerView *)tickerView valueForItemAtIndex:(NSUInteger)index
{
    return nil;
}

- (UIImage*) tickerView:(MKTickerView*) tickerView imageForItemAtIndex:(NSUInteger) index
{
    return nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self mydealloc];
}

- (void)mydealloc
{
    
    if (_event) {
        
        [_event mydealloc];
        _event = nil;
    }
    
    // ticker dealloc
    _ticker.stop = YES;
    _tickerItems = nil;
    _ticker = nil;
    _labelLocation = nil;
    _labelAddress = nil;
    _labelOfferTitle = nil;
    _labelOfferDescription = nil;
    _labelRule = nil;
}

@end
