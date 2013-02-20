//
//  AppViewMetricCell.h
//  Quick Metrics
//
//  Created by Alex Kurkin on 2/10/13.
//  Copyright (c) 2013 Brilliant Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface AppViewMetricCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *metricName;
@property (weak, nonatomic) IBOutlet UILabel *currentMetricValue;
@property (weak, nonatomic) IBOutlet UILabel *dayAgoMetricValue;
@property (weak, nonatomic) IBOutlet UILabel *weekAgoMetricValue;

@end
