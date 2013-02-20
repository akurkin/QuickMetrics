//
//  AKViewController.h
//  Quick Metrics
//
//  Created by Alex Kurkin on 2/9/13.
//  Copyright (c) 2013 Brilliant Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <RestKit/RestKit.h>

#import "SettingsViewController.h"

#import "AppView.h"
#import "User.h"
#import "MetricData.h"

#import "AppViewLayout.h"
#import "AppViewMetricCell.h"
#import "AppViewHeaderView.h"

#define MR_SHORTHAND
#import "CoreData+MagicalRecord.h"

@interface AKViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, AppViewHeaderDelegate>

@property (nonatomic, strong) AppView *appView;

- (void) loadPerformanceData;

@end
