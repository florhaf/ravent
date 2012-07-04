//
//  UIImage+ImageWithUIView.m
//

#import "UIImage+ImageWithUIView.h"

@implementation UIImage (ImageWithUIView)
#pragma mark -
#pragma mark TakeScreenShot

+ (UIImage *)imageWithUIView:(UIView *)view
{
//  CGSize screenShotSize = view.bounds.size;
//  UIImage *img;  
//  UIGraphicsBeginImageContext(screenShotSize);
//  CGContextRef ctx = UIGraphicsGetCurrentContext();
//  [view drawLayer:view.layer inContext:ctx];
//  img = UIGraphicsGetImageFromCurrentImageContext();
//  UIGraphicsEndImageContext();
    
    
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
  
  return resultingImage;
}
@end
