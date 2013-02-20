//
//  AppViewMetricCell.m
//  Quick Metrics
//
//  Created by Alex Kurkin on 2/10/13.
//  Copyright (c) 2013 Brilliant Consulting Inc. All rights reserved.
//

#import "AppViewMetricCell.h"

@implementation AppViewMetricCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void) setup {
    self.backgroundColor = [UIColor colorWithRed:254.0/255.0 green:254.0/255.0 blue:254.0/255.0 alpha:1.0];
    self.layer.shadowColor = [UIColor colorWithRed:53.0/255.0 green:52.0/255.0 blue:50.0/255.0 alpha:0.5].CGColor;
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeMake(0, 4.0);
    self.layer.shadowRadius = 4.0;
    self.layer.masksToBounds = NO;
    self.layer.cornerRadius = 4.0;
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
