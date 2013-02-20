//
//  MetricData.h
//  Quick Metrics
//
//  Created by Alex Kurkin on 2/12/13.
//  Copyright (c) 2013 Brilliant Consulting Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MetricData : NSObject

@property (nonatomic, copy) NSString *metricValue;
@property (nonatomic, copy) NSString *metricName;
@property (nonatomic, copy) NSString *metricField;

// attributes below added for convenience during request mapping
@property (nonatomic, copy) NSString *average_response_time;
@property (nonatomic, copy) NSString *calls_per_minute;
@property (nonatomic, copy) NSString *errors_per_minute;
@property (nonatomic, copy) NSString *sessions_active;
@property (nonatomic, copy) NSString *value;

@end
