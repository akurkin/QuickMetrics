//
//  AppView.h
//  Quick Metrics
//
//  Created by Alex Kurkin on 2/9/13.
//  Copyright (c) 2013 Brilliant Consulting Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface AppView : NSManagedObject

@property (nonatomic, retain) NSNumber * applicationId;
@property (nonatomic, retain) NSString * applicationName;

+ (AppView *) forApplicationId: (NSNumber *) applicationId
       andApplicationName: (NSString *) applicationName;


@end
