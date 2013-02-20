//
//  AppViewHeaderView.m
//  Quick Metrics
//
//  Created by Alex Kurkin on 2/10/13.
//  Copyright (c) 2013 Brilliant Consulting Inc. All rights reserved.
//

#import "AppViewHeaderView.h"

@interface AppViewHeaderView()

@property (nonatomic, strong) UILabel *applicationNameLabel;
@property (nonatomic, strong) UIImageView *settingsImageView;
@property (nonatomic, strong) UITapGestureRecognizer *tapOnSettings;

@end

@implementation AppViewHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        self.backgroundColor = [UIColor clearColor];

        self.applicationNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 258, 30)];
        self.applicationNameLabel.backgroundColor = [UIColor clearColor];
        self.applicationNameLabel.text = @"";
        self.applicationNameLabel.textColor = [UIColor whiteColor];
        self.applicationNameLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:24.0];
        self.applicationNameLabel.shadowColor = [UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:155.0/255.0 alpha:0.5];
        self.applicationNameLabel.shadowOffset = CGSizeMake(0, 1.0);
        self.applicationNameLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.applicationNameLabel];

        self.settingsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings"]];
        self.settingsImageView.frame = CGRectMake(280, 14, self.settingsImageView.frame.size.width, self.settingsImageView.frame.size.height);
        self.settingsImageView.userInteractionEnabled = YES;
        self.settingsImageView.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5].CGColor;
        self.settingsImageView.layer.shadowOffset = CGSizeMake(0, 2);
        self.settingsImageView.layer.shadowRadius = 2.0;
        self.settingsImageView.layer.shadowOpacity = 0.3;

        [self addSubview:self.settingsImageView];
    }

    return self;
}

- (void)setApplicationName:(NSString *)applicationName {
    if (applicationName != _applicationName) {
        _applicationName = applicationName;
        self.applicationNameLabel.text = applicationName;
    }
}

- (void)setDelegate:(id<AppViewHeaderDelegate>)delegate {
    if (delegate != _delegate) {
        _delegate = delegate;

        [self.settingsImageView removeGestureRecognizer:self.tapOnSettings];
        self.tapOnSettings = nil;

        self.tapOnSettings = [[UITapGestureRecognizer alloc] initWithTarget:delegate action:@selector(handleSettingsTap:)];
        [self.settingsImageView addGestureRecognizer:self.tapOnSettings];
    }
}

+ (CGSize)defaultSize {
    return CGSizeMake(280.0, 30.0);
}


@end
