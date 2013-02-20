//
//  AppViewHeaderView.h
//  Quick Metrics
//
//  Created by Alex Kurkin on 2/10/13.
//  Copyright (c) 2013 Brilliant Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol AppViewHeaderDelegate <NSObject>

- (void) handleSettingsTap: (UITapGestureRecognizer *) tap;

@end

@interface AppViewHeaderView : UICollectionReusableView

@property (nonatomic, strong) id <AppViewHeaderDelegate> delegate;
@property (nonatomic, strong) NSString *applicationName;

+ (CGSize)defaultSize;

@end
