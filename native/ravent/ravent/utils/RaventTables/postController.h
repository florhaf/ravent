//
//  postController.h
//  ravent
//
//  Created by florian haftman on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBAsyncImageView.h"

@interface postController : UIViewController {
    
    IBOutlet UITextView *_textView;
    IBOutlet UILabel *_labelName;
    IBOutlet JBAsyncImageView *_picUser;
    
    IBOutlet UIButton *_buttonPicture;
    IBOutlet UIButton *_buttonTake;
    IBOutlet UIButton *_buttonLib;
    IBOutlet UIButton *_buttonCancel;
}

- (void)hideModal;

- (IBAction)onPictureTap:(id)sender;
- (IBAction)onTakeTap:(id)sender;
- (IBAction)onLibTap:(id)sender;
- (IBAction)onCancelTap:(id)sender;

@end
