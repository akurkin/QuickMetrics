//
//  AKAppDelegate.m
//  Quick Metrics
//
//  Created by Alex Kurkin on 2/9/13.
//  Copyright (c) 2013 Brilliant Consulting Inc. All rights reserved.
//

#import "AKAppDelegate.h"

@implementation AKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [RKMIMETypeSerialization registerClass:[RKXMLReaderSerialization class] forMIMEType:RKMIMETypeXML];

    NSString *connectionHost = @"https://api.newrelic.com/api/v1/";

    [MagicalRecord setupCoreDataStackWithStoreNamed:@"QuickMetrics.sqlite"];

    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:connectionHost]];
    [RKObjectManager setSharedManager:manager];
    
    [manager.HTTPClient setDefaultHeader:@"x-api-key" value:[User sharedUser].apiKey];

    // setup response handlers for Applications call
    RKObjectMapping *applicationMapping = [RKObjectMapping requestMapping];
    [applicationMapping addAttributeMappingsFromDictionary:@{@"account_id" : @"accountId", @"name" : @"name", @"id" : @"applicationId"}];
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:applicationMapping pathPattern:@"accounts/:accountId/applications.json" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];

    // setup response handlers for Metric Data call
    RKObjectMapping *metricDataMapping = [RKObjectMapping mappingForClass:[MetricData class]];
    [metricDataMapping addAttributeMappingsFromDictionary:@{ @"name" : @"metricName",
                                          @"average_response_time" : @"average_response_time",
                                               @"calls_per_minute" : @"calls_per_minute",
                                              @"errors_per_minute" : @"errors_per_minute",
                                                @"sessions_active" : @"sessions_active",
                                                          @"value" : @"value",
     }];
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:metricDataMapping pathPattern:@"accounts/:accountId/metrics/data.json" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [MagicalRecord cleanUp];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"QuickMetrics.sqlite"];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord cleanUp];
}

@end
