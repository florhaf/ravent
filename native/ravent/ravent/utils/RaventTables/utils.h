//
//  utils.h
//  ravent
//
//  Created by florian haftman on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface utils : NSObject

+ (UIBarButtonItem *)createSquareBarButtonItemWithTitle:(NSString *)t imageNamed:(NSString *)img imageSelectedNamed:(NSString *)imgSelected target:(id)tgt action:(SEL)a;
+ (BOOL)isIphone5;

@end
