//
//  AppViewLayout.h
//  Quick Metrics
//
//  Created by Alex Kurkin on 2/10/13.
//  Copyright (c) 2013 Brilliant Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppViewHeaderView.h"

@interface AppViewLayout : UICollectionViewLayout

@property (nonatomic, assign) UIEdgeInsets itemInsets;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGFloat interItemSpacingY;
@property (nonatomic, assign) NSInteger numberOfColumns;

@property (nonatomic, strong) NSString *applicationName;

@end
