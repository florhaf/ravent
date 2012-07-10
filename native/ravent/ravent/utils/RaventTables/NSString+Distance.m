//
//  NSString+Distance.m
//  ravent
//
//  Created by florian haftman on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+Distance.h"

@implementation NSString (Distance)

#define METERS_TO_FEET  3.2808399
#define METERS_TO_MILES 0.000621371192
#define METERS_CUTOFF   1000
#define FEET_CUTOFF     3281
#define FEET_IN_MILES   5280

#define MILES_TO_KM 1.609344

// Return a string of the number to one decimal place and with commas & periods based on the locale.
- (NSString *)stringWithDouble:(double)value {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[NSLocale currentLocale]];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:1];
    return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:value]];
}

- (NSString *)stringWithDistance
{
    BOOL isMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
    double dDistInMiles = [self doubleValue];
    double dDistInKM = dDistInMiles * MILES_TO_KM;
    NSString *format;
    double distance;
    
    if (isMetric) {
        
        format = @"%@ km.";
        distance = dDistInKM;
    } else {
        
        format = @"%@ mi.";
        distance = dDistInMiles;
    }
    
    return [NSString stringWithFormat:format, [self stringWithDouble:distance]];
}



@end
