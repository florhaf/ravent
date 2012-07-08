//
//  controllers_events_Specials.m
//  ravent
//
//  Created by florian haftman on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_events_Specials.h"

@interface controllers_events_Specials ()

@end

@implementation controllers_events_Specials

- (id)initWithEvent:(models_Event *)event
{
    self = [super initWithNibName:@"views_events_Specials" bundle:nil];
    if (self) {

        _event = event;
        
        self.title = @"Gemster";
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

- (BOOL)isGemDropped:(NSString *)eid
{
    return true;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _tickerItems = [[NSArray alloc] initWithObjects:_event.name, nil];
    [_ticker reloadData];
    
    _labelLocation.text = _event.location;
    _labelAddress.text = _event.location;
    _labelOfferTitle.text = _event.offerTitle;
    _labelOfferDescription.text = _event.offerDescription;
    
    if ([self isGemDropped:_event.eid]) {
        
        _labelRule.text = @"Gem Dropped !";
    } else {
        
        _labelRule.text = @"Drop a gem to get this special";
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


@end
