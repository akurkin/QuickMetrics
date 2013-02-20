//
//  SettingsViewController.m
//  Quick Metrics
//
//  Created by Alex Kurkin on 2/10/13.
//  Copyright (c) 2013 Brilliant Consulting Inc. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (strong, nonatomic) RKObjectManager *loginManager;
@property (nonatomic, strong) NSArray *accounts;

@end

@implementation SettingsViewController

- (RKObjectManager *)loginManager
{
    if (!_loginManager) {
        NSString *connectionHost = @"https://api.newrelic.com/api/v1/";

        _loginManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:connectionHost]];
        _loginManager.requestSerializationMIMEType = RKMIMETypeXML;
        [_loginManager setAcceptHeaderWithMIMEType:@"application/xml"];

        [_loginManager.HTTPClient setDefaultHeader:@"x-api-key" value:[User sharedUser].apiKey];

        RKObjectMapping *userMapping = [RKObjectMapping requestMapping];
        [userMapping addAttributeMappingsFromDictionary:@{@"api-key" : @"apiKey", @"name" : @"name", @"id.text" : @"accountId"}];

        [_loginManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping pathPattern:@"accounts.xml" keyPath:@"accounts.account" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    }
    
    return _loginManager;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *changeApiKeyButtonImage = [UIImage imageNamed:@"api_key-normal"];
    UIImage *changeApiKeyButtonImageHighlighted = [UIImage imageNamed:@"api_key-highlighted"];

    [self.changeApiKeyButton setBackgroundImage:changeApiKeyButtonImage forState:UIControlStateNormal];
    [self.changeApiKeyButton setBackgroundImage:changeApiKeyButtonImageHighlighted forState:UIControlStateHighlighted];

    UIImage *changeAppButtonImage = [UIImage imageNamed:@"app-normal"];
    UIImage *changeAppButtonImageHighlighted = [UIImage imageNamed:@"app-highlighted"];

    [self.changeAppButton setBackgroundImage:changeAppButtonImage forState:UIControlStateNormal];
    [self.changeAppButton setBackgroundImage:changeAppButtonImageHighlighted forState:UIControlStateHighlighted];

    UIImageView *settingsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings"]];
    settingsImageView.frame = CGRectMake(280, 14, settingsImageView.frame.size.width, settingsImageView.frame.size.height);
    settingsImageView.userInteractionEnabled = YES;
    settingsImageView.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5].CGColor;
    settingsImageView.layer.shadowOffset = CGSizeMake(0, 2);
    settingsImageView.layer.shadowRadius = 2.0;
    settingsImageView.layer.shadowOpacity = 0.3;

    UITapGestureRecognizer *tapOnSettings = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnSettings:)];
    [settingsImageView addGestureRecognizer:tapOnSettings];

    [self.view addSubview:settingsImageView];

    UIPanGestureRecognizer *panOnAuthenticationView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanOnAuthenticationView:)];
    [self.authenticationView addGestureRecognizer:panOnAuthenticationView];

    self.authenticationView.bounds = CGRectMake(0, -144, self.authenticationView.frame.size.width, self.authenticationView.frame.size.height);

    self.usersTableView.alpha = 0.0;

    if ([[User sharedUser] hasName]) {
        self.welcomeMessageLabel.text = @"You are using app as";
        self.userNameLabel.text = [User sharedUser].name;
    } else {
        self.welcomeMessageLabel.text = @"Slide down";
        self.userNameLabel.text = @"to set API key";
    }
    
    self.apiKeyTextField.text = [User sharedUser].apiKey;
}

- (void) handleTapOnSettings: (UITapGestureRecognizer *) tap{
    [UIView animateWithDuration:0.2 animations:^{
        self.authenticationView.center = CGPointMake(self.authenticationView.center.x, 8.0);
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:YES completion:^{
            AKViewController *vc = (AKViewController *) self.delegate;
            vc.appView = [AppView findFirst];
            [vc loadPerformanceData];
        }];
    }];
}

- (IBAction)handleChangeApiKey:(UIButton *)sender {
    NSString *apiKey = self.apiKeyTextField.text;
    
    NSLog(@"login button clicked!, apiKey = %@", apiKey);
    
    if (apiKey) {
        [self.loginManager.HTTPClient setDefaultHeader:@"x-api-key" value:apiKey];

        NSString *url = @"accounts.xml";
        
        [self.loginManager getObjectsAtPath:url parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [AppView deleteAllMatchingPredicate:nil];
            [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];

            self.welcomeMessageLabel.text = @"Success!";
            self.userNameLabel.text = @"Select your account";
            NSLog(@"loaded %i accounts", [mappingResult array].count);

            [User sharedUser].apiKey = apiKey;

            [[RKObjectManager sharedManager].HTTPClient setDefaultHeader:@"x-api-key" value:apiKey];

            self.accounts = [mappingResult array];
            [self.usersTableView reloadData];
            [UIView animateWithDuration:0.2 animations:^{
                self.usersTableView.alpha = 1.0;
                self.apiKeyTextField.alpha = 0.0;
                self.changeApiKeyButton.alpha = 0.0;
            }];

        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            self.welcomeMessageLabel.text = @"Error!";
            self.userNameLabel.text = @"Check your API key";
            NSLog(@"error is: %@, operation = %@", error, operation);
        }];
        
        [self.apiKeyTextField resignFirstResponder];
    }

}

- (IBAction)selectAppPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"showApplicationsSegue" sender:self];
}

- (void) handlePanOnAuthenticationView: (UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.view];
    CGPoint newCenter = CGPointMake(self.authenticationView.center.x, self.authenticationView.center.y + translation.y);

//    NSLog(@"state: %i, newCenter: %@", pan.state, NSStringFromCGPoint(newCenter));
    float maxY = 282.0;
    float minY = 8.0;

    if (pan.state == UIGestureRecognizerStateChanged) {
        if (newCenter.y > maxY) {
            self.authenticationView.center = CGPointMake(self.authenticationView.center.x, maxY);
        } else if (newCenter.y < minY) {
            self.authenticationView.center = CGPointMake(self.authenticationView.center.x, minY);
        } else {
            self.authenticationView.center = newCenter;
        }

//        NSLog(@"handlePanOnAuth, translation: %@", NSStringFromCGPoint(translation));

        [pan setTranslation:CGPointZero inView:self.view];
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [pan velocityInView:self.view];

        [UIView animateWithDuration:0.2 animations:^{
            if (velocity.y > 0) {
                self.authenticationView.center = CGPointMake(self.authenticationView.center.x, maxY);
            } else if (velocity.y < 0) {
                self.authenticationView.center = CGPointMake(self.authenticationView.center.x, minY);
                [self.apiKeyTextField resignFirstResponder];
            }
        }];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *account = [self.accounts objectAtIndex:indexPath.row];

    [User sharedUser].apiKey = [account valueForKeyPath:@"apiKey.text"];
    [User sharedUser].accountId = [account valueForKeyPath:@"accountId"];
    [User sharedUser].name = [account valueForKeyPath:@"name.text"];

    self.welcomeMessageLabel.text = @"You are using app as";
    self.userNameLabel.text = [User sharedUser].name;

    [UIView animateWithDuration:0.2 animations:^{
        self.usersTableView.alpha = 0.0;

        self.apiKeyTextField.alpha = 1.0;
        self.changeApiKeyButton.alpha = 1.0;
        self.welcomeMessageLabel.alpha = 1.0;
        self.userNameLabel.alpha = 1.0;
    }];

    [self slideUpAuthenticationView];

    [self performSelector:@selector(selectAppPressed:) withObject:nil afterDelay:0.25];
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AccountCell"];
    NSDictionary *account = [self.accounts objectAtIndex:indexPath.row];
    NSLog(@"building cell for account: %@", account);

    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", [account valueForKeyPath:@"name.text"], [account valueForKey:@"accountId"]];

    return cell;
}

#pragma mark -
#pragma mark UI Helpers

- (void) slideUpAuthenticationView {
    [self slideAuthenticationView:YES];
}

- (void) slideDownAuthenticationView {
    [self slideAuthenticationView:NO];
}

- (void) slideAuthenticationView: (BOOL) up {
    float maxY = 282.0;
    float minY = 8.0;

    [UIView animateWithDuration:0.2 animations:^{
        if (up) {
            self.authenticationView.center = CGPointMake(self.authenticationView.center.x, minY);
        } else {
            self.authenticationView.center = CGPointMake(self.authenticationView.center.x, maxY);
        }
    }];
}

@end
