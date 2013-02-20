//
//  MetricData.m
//  Quick Metrics
//
//  Created by Alex Kurkin on 2/12/13.
//  Copyright (c) 2013 Brilliant Consulting Inc. All rights reserved.
//

#import "MetricData.h"

@implementation MetricData

-(BOOL)validateValue:(inout __autoreleasing id *)ioValue forKey:(NSString *)inKey error:(out NSError *__autoreleasing *)outError
{
    NSArray *acceptedKeys = @[@"average_response_time", @"calls_per_minute", @"errors_per_minute", @"sessions_active", @"value"];
//    NSLog(@"validation: %@, %u", inKey, [ @[@"average_response_time", @"calls_per_minute", @"errors_per_minute", @"sessions_active", @"value"] indexOfObject:inKey ] );
    if ([ acceptedKeys indexOfObject:inKey ] < acceptedKeys.count) {
        NSLog(@"trying to validate key: %@", inKey);
        self.metricField = inKey;
        NSNumber *val = *ioValue;

        if ([self.metricName isEqualToString:@"HttpDispatcher"] && [inKey isEqualToString:@"average_response_time"]) {
            self.metricValue = [NSString stringWithFormat:@"%g ms", round([val floatValue] * 1000.0)];
        } else if ([self.metricName isEqualToString:@"EndUser"]) {
            self.metricValue = [NSString stringWithFormat:@"%g s", round([val floatValue] * 100.0) / 100.0];
        } else if ([self.metricName isEqualToString:@"EndUser/Apdex"]) {
            self.metricValue = [NSString stringWithFormat:@"%g %%", round([val floatValue] * 100.0)];
        } else {
            self.metricValue = [NSString stringWithFormat:@"%i", [val intValue]];
        }

    }

    return YES;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ - %@", self.metricName, self.metricField, self.metricValue];
}

@end
