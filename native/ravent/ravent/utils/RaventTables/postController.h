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

@interface postController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    
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
    
    BOOL _isKeyboardShowing;
    BOOL _isForEvent;
    
    NSString *_toId; // id for an event of a friend
    
    NSString *_base64Picture;
    models_Comment *_comment;
}

@property (nonatomic, assign) BOOL isForEvent;
@property (nonatomic, retain) NSString *toId;

- (void)hideModal;

- (IBAction)onPictureTap:(id)sender;
- (IBAction)onTakeTap:(id)sender;
- (IBAction)onLibTap:(id)sender;
- (IBAction)onCancelTap:(id)sender;
- (IBAction)onRemoveTap:(id)sender;

@end
