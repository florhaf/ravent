//
//  AWIconAnnotation.m
//  ravent
//
//  Created by florian haftman on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AWIconAnnotation.h"

@implementation AWIconAnnotation

- (id)initWithAnnotation:(id)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Compensate frame a bit so everything's aligned
        [self setCenterOffset:CGPointMake(-9, -3)];
        [self setCalloutOffset:CGPointMake(-2, 3)];
        
        // Add the pin icon
        iconView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 0, 32, 37)];
        [self addSubview:iconView];   
    }
    return self;
}

- (void)setAnnotation:(id)annotation {
    
    [super setAnnotation:annotation];
    
    //Place *place = (Place *)annotation;
//    icon = [UIImage imageNamed:
//            [NSString stringWithFormat:@"pin_%d.png", [place.icon intValue]]];
    [iconView setImage:icon];
}

@end
