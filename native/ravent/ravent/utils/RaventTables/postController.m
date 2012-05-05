//
//  postController.m
//  ravent
//
//  Created by florian haftman on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "postController.h"
#import "models_User.h"

@implementation postController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.title = @"Ravent";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [_textView becomeFirstResponder];
    
    _picUser.imageURL = [NSURL URLWithString:[models_User crtUser].picture];
    _labelName.text = [NSString stringWithFormat:@"%@ %@", [models_User crtUser].firstName, [models_User crtUser].lastName];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hideModal)];        
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(post)];        
    self.navigationItem.leftBarButtonItem = postButton;
}

- (void)post
{
    [self hideModal];
}

- (void)hideModal
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onPictureTap:(id)sender
{
    [_textView resignFirstResponder];
}

- (IBAction)onTakeTap:(id)sender
{
    
}

- (IBAction)onLibTap:(id)sender
{
    
}

- (IBAction)onCancelTap:(id)sender
{
    [_textView becomeFirstResponder];
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

@end
