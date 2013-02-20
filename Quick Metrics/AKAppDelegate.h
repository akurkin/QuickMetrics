//
//  AKAppDelegate.h
//  Quick Metrics
//
//  Created by Alex Kurkin on 2/9/13.
//  Copyright (c) 2013 Brilliant Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "RKXMLReaderSerialization.h"
#import "User.h"
#import "MetricData.h"

@interface AKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
