//
//  controllers_events_Pic_big.h
//  ravent
//
//  Created by florian haftman on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBAsyncImageView.h"

@interface controllers_events_Pic_big : UIViewController<UIScrollViewDelegate, JBAsyncImageViewDelegate> {
    
    IBOutlet JBAsyncImageView *_pic;
    IBOutlet UIScrollView *_scrollview;
    
    NSString *_url;
}

- (id)initWithPic:(NSString *)url;

@end
