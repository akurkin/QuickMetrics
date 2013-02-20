//
//  User.m
//  Quick Metrics
//
//  Created by Alex Kurkin on 2/10/13.
//  Copyright (c) 2013 Brilliant Consulting Inc. All rights reserved.
//

#import "User.h"

@implementation User

+ (User *) sharedUser{
    static User *sharedUser = nil;
    static dispatch_once_t onceToken;
    
    //    NSLog(@"[ USER ] sharedUser = %@", sharedUser);
    
    dispatch_once(&onceToken, ^{
        NSLog(@"initializing sharedUser");
        NSString *apiKey;
        NSString *accountId;
        NSString *name;

        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"QuickMetrics" accessGroup:nil];

        apiKey = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
        accountId = [wrapper objectForKey:(__bridge id)(kSecAttrType)];
        name = [wrapper objectForKey:(__bridge id) (kSecAttrDescription)];

        sharedUser = [[User alloc] init];
        if (apiKey && accountId) {
            sharedUser.apiKey = apiKey;
            sharedUser.accountId = accountId;
            sharedUser.name = name;
        } else {
            NSLog(@"no apiKey or accountId available!");
        }
    });
    
    return sharedUser;
}

- (BOOL)hasName {
    return self.name && ![self.name isEqualToString:@""];
}

- (BOOL) canMakeRequests {
    return self.apiKey && self.accountId;
}

- (void)setApiKey:(NSString *)newApiKey
{
    if (_apiKey != newApiKey) {
        _apiKey = newApiKey;
        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"QuickMetrics" accessGroup:nil];
        [wrapper setObject:newApiKey forKey:(__bridge id)(kSecAttrService)];
        NSLog(@"apiKey updated");
    }
}

- (void)setAccountId:(NSString *)newAccountId
{
    if (_accountId != newAccountId) {
        _accountId = newAccountId;
        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"QuickMetrics" accessGroup:nil];
        [wrapper setObject:newAccountId forKey:(__bridge id)(kSecAttrType)];
        NSLog(@"accountId updated");
    }
}

- (void)setName:(NSString *)newName {
    if (_name != newName) {
        _name = newName;
        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"QuickMetrics" accessGroup:nil];
        [wrapper setObject:newName forKey:(__bridge id)(kSecAttrDescription)];
        NSLog(@"name updated");
    }
}

@end
