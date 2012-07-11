//
//  controllers_events_Pic_big.m
//  ravent
//
//  Created by florian haftman on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "controllers_events_Pic_big.h"
#import "GANTracker.h"
#import "models_User.h"

@interface controllers_events_Pic_big ()

@end

@implementation controllers_events_Pic_big

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Gemster";
    }
    return self;
}

- (id)initWithPic:(NSString *)url
{
    self = [super initWithNibName:@"views_events_Pic_Big" bundle:nil];
    if (self) {
        self.title = @"Gemster";
        _url = url;
        
        [self trackPageView:@"events_details_album" forEvent:nil];
    }
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _pic;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hideAllModal)];        
    self.navigationItem.rightBarButtonItem = doneButton;
    
    _pic.delegate = self;
    _pic.imageURL = [NSURL URLWithString:_url];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    
    _scrollview.minimumZoomScale=0.5;
    _scrollview.maximumZoomScale=6.0;
    
}

-(void)imageView:(JBAsyncImageView *)sender loadedImage:(UIImage *)imageLoaded fromURL:(NSURL *)url
{
    _scrollview.contentSize=sender.frame.size;
    _pic.clipsToBounds = YES;
    _pic.contentMode = UIViewContentModeScaleAspectFit;
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

- (void)hideAllModal
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
