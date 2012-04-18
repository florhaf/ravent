//
//  AWIconAnnotation.h
//  ravent
//
//  Created by florian haftman on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface AWIconAnnotation : MKPinAnnotationView {
    
    UIImage *icon;
    UIImageView *iconView;
}

@end
