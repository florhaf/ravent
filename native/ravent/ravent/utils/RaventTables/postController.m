//
//  postController.m
//  ravent
//
//  Created by florian haftman on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "postController.h"
#import "models_User.h"
#import "NSData+Base64.h"
#import "MBProgressHUD.h"
#import "YRDropdownView.h"

@implementation postController

@synthesize isForEvent = _isForEvent;
@synthesize toId = _toId;

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
    _isKeyboardShowing = YES;
    
    _picUser.imageURL = [NSURL URLWithString:[models_User crtUser].picture];
    _labelName.text = [NSString stringWithFormat:@"%@ %@", [models_User crtUser].firstName, [models_User crtUser].lastName];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hideModal)];        
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(post)];        
    self.navigationItem.leftBarButtonItem = postButton;
}

- (void)post
{
    if (_base64Picture == nil && (_textView.text == nil || [_textView.text isEqualToString:@""])) {
        
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    _comment = [[models_Comment alloc] initWithDelegate:self andSelector:nil];
    
    _comment.pictureContent = _base64Picture;
    _comment.message = _textView.text;
    _comment.uid = [models_User crtUser].uid;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (_isForEvent) {
        
        [params setValue:_toId forKey:@"eid"];
    } else {
    
        [params setValue:_toId forKey:@"friendid"];
    }
    
    [params setValue:_base64Picture forKey:@"attachment"];
    [params setValue:_textView.text forKey:@"message"];
    [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
    [params setValue:[models_User crtUser].uid forKey:@"userid"];
    
    [_comment post:params success:@selector(onPostSuccess:) failure:@selector(onPostFailure:)];
}

- (void)onPostSuccess:(NSString *)response
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self hideModal];
}

- (void)onPostFailure:(NSMutableDictionary *)response
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    NSString *errorMsg = (NSString *)[response valueForKey:@"statusCode"];
    
    [YRDropdownView showDropdownInView:self.view 
                                 title:@"Error" 
                                detail:errorMsg
                                 image:[UIImage imageNamed:@"dropdown-alert"]
                              animated:YES];
}

- (void)hideModal
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onPictureTap:(id)sender
{
    if (_isKeyboardShowing) {
        
        [_textView resignFirstResponder];
        _isKeyboardShowing = NO;
    } else {
     
        [_textView becomeFirstResponder];
        _isKeyboardShowing = YES;
    }
}

- (IBAction)onTakeTap:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        
        [self presentModalViewController:imagePicker animated:YES];
    } else {
        
        [self onLibTap:sender];
    }
}

- (IBAction)onLibTap:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    
    [self presentModalViewController:imagePicker animated:YES];
}

- (IBAction)onCancelTap:(id)sender
{
    [_textView becomeFirstResponder];
    _isKeyboardShowing = YES;
}

- (IBAction)onRemoveTap:(id)sender
{
    [_picture setImage:nil];
    [_picture setHidden:YES];
    [_pictureBorder setHidden:YES];
    [_removeButton setHidden:YES];
    
    _base64Picture = nil;
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Access the uncropped image from info dictionary
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    _base64Picture = [imageData base64EncodingWithLineLength:0];
    
    [_picture setImage:image];
    [_picture setHidden:NO];
    [_pictureBorder setHidden:NO];
    [_removeButton setHidden:NO];
    
    [self dismissModalViewControllerAnimated:YES];
    
    [_textView becomeFirstResponder];
    _isKeyboardShowing = YES;
}

@end
