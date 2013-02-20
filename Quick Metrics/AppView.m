//
//  AppView.m
//  Quick Metrics
//
//  Created by Alex Kurkin on 2/9/13.
//  Copyright (c) 2013 Brilliant Consulting Inc. All rights reserved.
//

#import "AppView.h"


@implementation AppView

@dynamic applicationId;
@dynamic applicationName;

+ (AppView *) forApplicationId:(NSNumber *)applicationId andApplicationName:(NSString *)applicationName {
    AppView *existingAppView = [AppView findFirst];

    NSLog(@"existingAppView: %@", existingAppView);

    if (existingAppView) {
        if([existingAppView.applicationId isEqualToNumber:applicationId]) return existingAppView;
        existingAppView.applicationId = applicationId;
        existingAppView.applicationName = applicationName;
        [existingAppView setValue:applicationId forKey:@"applicationId"];

        NSLog(@"existingAppView after change: %@", existingAppView);

        return existingAppView;
    } else {
        AppView *newAppView = [AppView createEntity];
        newAppView.applicationId = applicationId;
        newAppView.applicationName = applicationName;

        return newAppView;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ -> %@", self.applicationId, self.applicationName];
}

@end
