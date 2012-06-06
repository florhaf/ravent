//
//  UIToolbar+CustomImage.m
//  ravent
//
//  Created by florian haftman on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIToolbar+CustomImage.h"

@implementation UIToolbar (CustomImage)

- (void)drawRect:(CGRect)rect
{
    UIImage *image = [UIImage imageNamed:@"toolbar"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end
