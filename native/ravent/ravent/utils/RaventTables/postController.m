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

#import "YRDropdownView.h"
#import "UIView+Animation.h"
#import "controllers_App.h"

@implementation postController

@synthesize isForEvent = _isForEvent;
@synthesize isForPicture = _isForPicture;
@synthesize toId = _toId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isForPicture:(BOOL)value
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isForPicture = value;
        self.title = @"Gemster";
    }
    return self;
}

- (void)setIsForEvent:(BOOL)isForEvent
{
    _isForEvent = isForEvent;
    
    if (_isForEvent) {
        
        _placeHolder = @"Post on this event wall";
    } else {
        
        _placeHolder = @"Post on this friend wall";
    }
}

-(void) textViewDidChange:(UITextView *)textView
{
    if(_textView.text.length == 0){
        
        [_placeholderLabel setHidden:NO];
    } else {
        
        [_placeholderLabel setHidden:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [_textView becomeFirstResponder];
    _isKeyboardShowing = YES;
    
    if (_isForPicture) {
     
        [self onPictureTap:nil];
    }
    
    _picUser.imageURL = [NSURL URLWithString:[models_User crtUser].picture];
    _labelName.text = [NSString stringWithFormat:@"%@ %@", [models_User crtUser].firstName, [models_User crtUser].lastName];
    
    UIImage *donei = [UIImage imageNamed:@"doneButton"];
    UIButton *doneb = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneb addTarget:self action:@selector(hideModal) forControlEvents:UIControlEventTouchUpInside];
    [doneb setImage:donei forState:UIControlStateNormal];
    [doneb setFrame:CGRectMake(0, 0, donei.size.width, donei.size.height)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithCustomView:doneb];       
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UIImage *posti = [UIImage imageNamed:@"postButton"];
    UIButton *postb = [UIButton buttonWithType:UIButtonTypeCustom];
    [postb addTarget:self action:@selector(post) forControlEvents:UIControlEventTouchUpInside];
    [postb setImage:posti forState:UIControlStateNormal];
    [postb setFrame:CGRectMake(0, 0, posti.size.width, posti.size.height)];
    UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithCustomView:postb];       
    self.navigationItem.leftBarButtonItem = postButton;
    
    self.title = @"Gemster";
    
    if (_isForEvent) {
        
        _placeholderLabel.text = @"Post on this event wall";
    } else {
        
        _placeholderLabel.text = @"Post on your friend Timeline";
    }
}

- (void)post
{
    if (_imageData == nil && (_textView.text == nil || [_textView.text isEqualToString:@""])) {
        
        return;
    }
    
    if (_hud == nil) {
        
        [_textView resignFirstResponder];
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];   
    }
    
    _comment = [[models_Comment alloc] initWithDelegate:self andSelector:nil];
    
    _comment.message = _textView.text;
    _comment.uid = [models_User crtUser].uid;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (_isForEvent) {
        
        [params setValue:_toId forKey:@"eid"];
    } else {
    
        [params setValue:_toId forKey:@"friendid"];
    }

    [params setValue:_imageData forKey:@"attachment"];
    [params setValue:_textView.text forKey:@"message"];
    [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
    [params setValue:[models_User crtUser].uid forKey:@"userid"];
    
    [_comment post:params success:@selector(onPostSuccess:) failure:@selector(onPostFailure:)];
    
    if (_isForEvent && _imageData != nil) {
        
        params = nil;
        params = [[NSMutableDictionary alloc] init];
        
        [params setValue:[models_User crtUser].uid forKey:@"friendid"];
        
        [params setValue:_imageData forKey:@"attachment"];
        [params setValue:_textView.text forKey:@"message"];
        [params setValue:[models_User crtUser].accessToken forKey:@"access_token"];
        [params setValue:[models_User crtUser].uid forKey:@"userid"];
        
        [_comment post:params success:@selector(onPostSuccess:) failure:@selector(onPostFailure:)];        
    }
}

- (void)onPostSuccess:(NSString *)response
{   
    if (_isForEvent) {

        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadComments" object:nil];   
        
        if (_imageData != nil) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadPictures" object:nil];
        }
    }
    
    _textView.text = nil;
    _imageData = nil;
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [self performSelector:@selector(hideModal) withObject:nil afterDelay:0.2];
    
    
}

- (void)onPostFailure:(NSMutableDictionary *)response
{
    [_textView becomeFirstResponder];
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    NSString *errorMsg = (NSString *)[response valueForKey:@"statusCode"];
    
    [YRDropdownView showDropdownInView:[controllers_App instance].view 
                                 title:@"Error" 
                                detail:errorMsg
                                 image:[UIImage imageNamed:@"dropdown-alert"]
                              animated:YES];
}

- (void)hideModal
{
    if ((_textView.text != nil && ![_textView.text isEqualToString:@""]) || _imageData != nil) {
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Gemster"
                                  message:@"Send your message?"
                                  delegate:self
                                  cancelButtonTitle:@"NO"
                                  otherButtonTitles:@"YES",
                                  nil];
        [alertView show];
        
        return;
    }
    
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [_textView resignFirstResponder];
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self performSelector:@selector(post) withObject:nil afterDelay:0.1];
    } else {
        
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)onPictureTap:(id)sender
{
    if (_isKeyboardShowing) {
        
        [_textView resignFirstResponder];
        _isKeyboardShowing = NO;
        
        [_buttonsContainer raceTo:CGPointMake(0, 199) withSnapBack:NO];
    } else {
     
        [_textView becomeFirstResponder];
        _isKeyboardShowing = YES;
        
        [_buttonsContainer raceTo:CGPointMake(0, 415) withSnapBack:NO];
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
    
    if (_isForPicture) {
        
        [self hideModal];
        return;
    }
    
    [_buttonsContainer raceTo:CGPointMake(0, 415) withSnapBack:NO];
}

- (IBAction)onRemoveTap:(id)sender
{
    [_picture setImage:nil];
    [_picture setHidden:YES];
    [_pictureBorder setHidden:YES];
    [_removeButton setHidden:YES];
    
    //_base64Picture = nil;
    _imageData = nil;
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    [_textView becomeFirstResponder];
    _isKeyboardShowing = YES;
    
    // Access the uncropped image from info dictionary
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    [_picture setImage:image];
    [_picture setHidden:NO];
    [_pictureBorder setHidden:NO];
    [_removeButton setHidden:NO];
    
    _imageData = UIImageJPEGRepresentation(image, 1.0);
    //_base64Picture = [_imageData base64EncodingWithLineLength:0];
}

- (void)dealloc
{
    _textView = nil;
    _labelName = nil;
    _picUser = nil;
    
    _buttonPicture = nil;
    _buttonTake = nil;
    _buttonLib = nil;
    _buttonCancel = nil;
    
    _picture = nil;
    _pictureBorder = nil;
    _removeButton = nil;
    
    _buttonsContainer = nil;
    
    
    _toId = nil; // id for an event of a friend
    _placeHolder = nil;
    
    _base64Picture = nil;
    _imageData = nil;
    _comment = nil;
}

@end
