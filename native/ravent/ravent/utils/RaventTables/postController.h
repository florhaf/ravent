//
//  postController.h
//  ravent
//
//  Created by florian haftman on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBAsyncImageView.h"
#import "models_Comment.h"

typedef enum {
    event,
    user
} postTo;

@interface postController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, UIAlertViewDelegate> {
    
    IBOutlet UITextView *_textView;
    IBOutlet UILabel *_labelName;
    IBOutlet JBAsyncImageView *_picUser;
    
    IBOutlet UIButton *_buttonPicture;
    IBOutlet UIButton *_buttonTake;
    IBOutlet UIButton *_buttonLib;
    IBOutlet UIButton *_buttonCancel;
    
    IBOutlet UIImageView *_picture;
    IBOutlet UIImageView *_pictureBorder;
    IBOutlet UIButton *_removeButton;
    
    IBOutlet UIView *_buttonsContainer;
    IBOutlet UILabel *_placeholderLabel;
    
    BOOL _isKeyboardShowing;
    BOOL _isForEvent;
    BOOL _isForPicture;
    BOOL _isPlaceHolderShowing;
    
    NSString *_toId; // id for an event of a friend
    NSString *_placeHolder;
    
    NSString *_base64Picture;
    NSData *_imageData;
    models_Comment *_comment;
}

@property (nonatomic, assign) BOOL isForEvent;
@property (nonatomic, assign) BOOL isForPicture;
@property (nonatomic, retain) NSString *toId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isForPicture:(BOOL)value;

- (void)hideModal;

- (IBAction)onPictureTap:(id)sender;
- (IBAction)onTakeTap:(id)sender;
- (IBAction)onLibTap:(id)sender;
- (IBAction)onCancelTap:(id)sender;
- (IBAction)onRemoveTap:(id)sender;

@end
