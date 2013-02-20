//
//  ApplicationsViewController.m
//  Quick Metrics
//
//  Created by Alex Kurkin on 2/11/13.
//  Copyright (c) 2013 Brilliant Consulting Inc. All rights reserved.
//

#import "ApplicationsViewController.h"

@interface ApplicationsViewController ()

@property (nonatomic, strong) NSArray *applications;

@end

@implementation ApplicationsViewController

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

    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"accounts/%@/applications.json", [User sharedUser].accountId] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"apps: %@", [mappingResult array]);
        self.applications = [mappingResult array];
        [self.applicationsTableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"failed to retrieve apps: %@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.applications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ApplicationCell"];
    cell.textLabel.text = [[self.applications objectAtIndex:indexPath.row] valueForKeyPath:@"name"];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue UltraLight" size:12.0];
//    cell.textLabel.minimumScaleFactor = 0.5;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;

    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *app = [self.applications objectAtIndex:indexPath.row];
    [AppView forApplicationId:[app valueForKey:@"applicationId"] andApplicationName:[app valueForKey:@"name"]];

    [[NSManagedObjectContext defaultContext] saveToPersistentStore:nil];

    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
