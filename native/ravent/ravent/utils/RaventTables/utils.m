//
//  utils.m
//  ravent
//
//  Created by florian haftman on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "utils.h"

@implementation utils

+ (UIBarButtonItem *)createSquareBarButtonItemWithTitle:(NSString *)t imageNamed:(NSString *)img imageSelectedNamed:(NSString *)imgSelected target:(id)tgt action:(SEL)a
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    // Since the buttons can be any width we use a thin image with a stretchable center point
    UIImage *buttonImage = [[UIImage imageNamed:img] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    UIImage *buttonPressedImage = [[UIImage imageNamed:imgSelected] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    
    if (t != nil) {
     
        [[button titleLabel] setFont:[UIFont boldSystemFontOfSize:12.0]];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setTitleShadowColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateNormal];
        [button setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
        [[button titleLabel] setShadowOffset:CGSizeMake(0.0, 1.0)];
        
        CGRect buttonFrame = [button frame];
        buttonFrame.size.width = [t sizeWithFont:[UIFont boldSystemFontOfSize:12.0]].width + 24.0;
        buttonFrame.size.height = buttonImage.size.height;
        [button setFrame:buttonFrame];
        
        [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
        
        [button setTitle:t forState:UIControlStateNormal];
    }
    
    [button addTarget:tgt action:a forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return buttonItem;
}

+ (BOOL)isIphone5
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    return (screenBounds.size.height == 568);
}

@end
