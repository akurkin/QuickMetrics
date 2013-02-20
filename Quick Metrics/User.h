//
//  User.h
//  Quick Metrics
//
//  Created by Alex Kurkin on 2/10/13.
//  Copyright (c) 2013 Brilliant Consulting Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeychainItemWrapper.h"

@interface User : NSObject
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *apiKey;
@property (nonatomic) NSString *accountId;
@property (nonatomic) NSString *name;

+ (User *) sharedUser;
- (BOOL) hasName;
- (BOOL) canMakeRequests;

@end
