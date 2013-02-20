//
//  AKViewController.m
//  Quick Metrics
//
//  Created by Alex Kurkin on 2/9/13.
//  Copyright (c) 2013 Brilliant Consulting Inc. All rights reserved.
//

#import "AKViewController.h"

static NSString * const AppViewMetricCellIdentifier = @"AppViewMetricCell";

@interface AKViewController ()

@property (nonatomic, weak) IBOutlet AppViewLayout *appViewLayout;
@property (nonatomic, strong) NSDictionary *appViewMetrics;
@property (nonatomic, strong) NSMutableDictionary *appViewMetricValues;
@property (nonatomic, strong) NSDateFormatter *requestDateFormatter;

@end

@implementation AKViewController


#pragma mark -
#pragma mark Redefined accessors for attributes

- (NSDateFormatter *)requestDateFormatter {
    if (!_requestDateFormatter) {
        _requestDateFormatter = [[NSDateFormatter alloc] init];
        [_requestDateFormatter  setDateFormat:@"yyyy-MM-dd'T'HH:mm:00"];
        _requestDateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    }
    return _requestDateFormatter;
}

- (NSDictionary *) appViewMetrics {
    if (!_appViewMetrics) {
        _appViewMetrics = [NSDictionary dictionaryWithObjectsAndKeys:
                           @{@"name" : @"Response time", @"metricName" : @"HttpDispatcher", @"metricField" : @"average_response_time"}, @(0),
                           @{@"name" : @"Page load time", @"metricName" : @"EndUser", @"metricField" : @"average_response_time"}, @(1),
                           @{@"name" : @"Requests/minute", @"metricName" : @"HttpDispatcher", @"metricField" : @"calls_per_minute"}, @(2),
                           @{@"name" : @"Active sessions", @"metricName" : @"EndUser/Session", @"metricField" : @"sessions_active"}, @(3),
                           @{@"name" : @"Error rate", @"metricName" : @"Errors/all", @"metricField" : @"errors_per_minute"}, @(4),
                           @{@"name" : @"User Apdex", @"metricName" : @"EndUser/Apdex", @"metricField" : @"value"}, @(5),
                           nil];
    }

    return _appViewMetrics;
}

- (NSMutableDictionary *)appViewMetricValues {
    if (!_appViewMetricValues) {
        _appViewMetricValues = [NSMutableDictionary dictionary];
        [self.appViewMetrics enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL *stop){
            [_appViewMetricValues setObject:
             [NSMutableDictionary dictionaryWithDictionary:@{@"now" : @"", @"day" : @"", @"week" : @""}] forKey:key];
        }];
    }

    return _appViewMetricValues;
}

- (void)setAppView:(AppView *)appView {
    if (_appView != appView) {
        _appView = appView;
        [self loadPerformanceData];
    }
}

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasGoneInBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];


//    [AppView deleteAllMatchingPredicate:nil];

    // pull-to-refresh functionality
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor colorWithRed:53.0/255.0 green:52.0/255.0 blue:50.0/255.0 alpha:1.0];
    [refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];

    [self.collectionView registerClass:[AppViewHeaderView class] forSupplementaryViewOfKind:@"AppViewHeader" withReuseIdentifier:@"AppViewHeader"];

    self.appView = [AppView findFirst];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (!self.appView && ![[User sharedUser] canMakeRequests]) {
        [self handleSettingsTap:nil];
    }
}

#pragma mark -
#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.appView) {
        return 6;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AppViewMetricCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AppViewMetricCellIdentifier forIndexPath:indexPath];
    NSDictionary *values = [self.appViewMetricValues objectForKey:@( indexPath.row )];

    if (div(indexPath.row, 2).rem == 1) {
        cell.currentMetricValue.textColor = [UIColor colorWithRed:239.0/255.0 green:71.0/255.0 blue:35.0/255.0 alpha:1.0];
        cell.dayAgoMetricValue.textColor = [UIColor colorWithRed:239.0/255.0 green:71.0/255.0 blue:35.0/255.0 alpha:0.75];
        cell.weekAgoMetricValue.textColor = [UIColor colorWithRed:239.0/255.0 green:71.0/255.0 blue:35.0/255.0 alpha:0.5];
    } else {
        cell.currentMetricValue.textColor = [UIColor colorWithRed:255.0/255.0 green:32.0/255.0 blue:111.0/255.0 alpha:1.0];
        cell.dayAgoMetricValue.textColor = [UIColor colorWithRed:255.0/255.0 green:32.0/255.0 blue:111.0/255.0 alpha:0.75];
        cell.weekAgoMetricValue.textColor = [UIColor colorWithRed:255.0/255.0 green:32.0/255.0 blue:111.0/255.0 alpha:0.5];
    }
    
    NSDictionary *appViewMetricForCell = [self.appViewMetrics objectForKey:@(indexPath.row)];
    
//    NSLog(@"appViewMetricForCell: %@ for row: %@", appViewMetricForCell, indexPath);
    
//    NSLog(@"values are: %@", values);

    cell.currentMetricValue.text = [values objectForKey:@"now"];
    cell.dayAgoMetricValue.text = [values objectForKey:@"day"];
    cell.weekAgoMetricValue.text = [values objectForKey:@"week"];

    cell.metricName.text = [appViewMetricForCell objectForKey:@"name"];

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    AppViewHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:@"AppViewHeader" withReuseIdentifier:@"AppViewHeader" forIndexPath:indexPath];
    [headerView setApplicationName:self.appView.applicationName];
    headerView.delegate = self;

    return headerView;
}

#pragma mark -
#pragma mark UICollectionViewDelegate


#pragma mark -
#pragma mark Actions

- (void)startRefresh:(UIRefreshControl *)refreshControl {
    NSLog(@"sender: %@", refreshControl);
    [refreshControl beginRefreshing];

    [self loadPerformanceData];
    
    [refreshControl endRefreshing];
}

#pragma mark -
#pragma mark AppViewHeaderDelegate

- (void) handleSettingsTap: (UITapGestureRecognizer *) tap {
    [self performSegueWithIdentifier:@"settingsSegue" sender:self];
}

#pragma mark -
#pragma mark Reloading data methods

- (void) loadPerformanceData {
    if (![[User sharedUser] canMakeRequests] || !self.appView) {
        [self.collectionView reloadData];
        return;
    }
    
    NSDateComponents *current = [[NSDateComponents alloc] init];
    [current setMinute:-30];
    NSDateComponents *daily = [[NSDateComponents alloc] init];
    [daily setDay:-1];
    NSDateComponents *weekly = [[NSDateComponents alloc] init];
    [weekly setWeek:-1];

    NSDate *currentBeginDate = [[NSCalendar currentCalendar] dateByAddingComponents:current toDate:[NSDate date] options:0];
    NSDate *dailyBeginDate = [[NSCalendar currentCalendar] dateByAddingComponents:daily toDate:[NSDate date] options:0];
    NSDate *weeklyBeginDate = [[NSCalendar currentCalendar] dateByAddingComponents:weekly toDate:[NSDate date] options:0];

    NSString * beginDateString = [self.requestDateFormatter stringFromDate: currentBeginDate];
    NSString * dailyBeginDateString = [self.requestDateFormatter stringFromDate: dailyBeginDate];
    NSString * weeklyBeginDateString = [self.requestDateFormatter stringFromDate: weeklyBeginDate];
    NSString * endDateString = [self.requestDateFormatter stringFromDate: [NSDate date]];
    
    NSLog(@"dateFormatter: %@, beginDateString: %@", self.requestDateFormatter, beginDateString);
    
    [self.appViewMetrics enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSDictionary *metric, BOOL *stop) {
        NSString *metricName = [metric valueForKey:@"metricName"];
        NSString *metricField = [metric valueForKey:@"metricField"];
        
//        NSLog(@"loading data for: %@, appview: %@", metric, self.appView);

        NSString *url = [NSString stringWithFormat:@"accounts/%@/metrics/data.json", [User sharedUser].accountId];

        [[RKObjectManager sharedManager] getObjectsAtPath:url
                                           parameters:@{ @"agent_id" : self.appView.applicationId,
                                                          @"metrics" : metricName,
                                                            @"field" : metricField,
                                                            @"begin" : beginDateString,
                                                              @"end" : endDateString,
                                                          @"summary" : @(1) }
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  MetricData *metricData = [[mappingResult array] objectAtIndex:0];
                                                  NSMutableDictionary *values = [self.appViewMetricValues objectForKey:key];
                                                  [values setValue:metricData.metricValue forKey:@"now"];

                                                  [self.collectionView reloadData];
                                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"error: %@", error);
                                              }];

        [[RKObjectManager sharedManager] getObjectsAtPath:url
                                           parameters:@{ @"agent_id" : self.appView.applicationId,
                                                          @"metrics" : metricName,
                                                            @"field" : metricField,
                                                            @"begin" : dailyBeginDateString,
                                                              @"end" : endDateString,
                                                          @"summary" : @(1) }
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  MetricData *metricData = [[mappingResult array] objectAtIndex:0];
                                                  NSMutableDictionary *values = [self.appViewMetricValues objectForKey:key];
                                                  [values setValue:metricData.metricValue forKey:@"day"];
                                                  
                                                  [self.collectionView reloadData];
                                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"error: %@", error);
                                              }];

        [[RKObjectManager sharedManager] getObjectsAtPath:url
                                           parameters:@{ @"agent_id" : self.appView.applicationId,
                                                          @"metrics" : metricName,
                                                            @"field" : metricField,
                                                            @"begin" : weeklyBeginDateString,
                                                              @"end" : endDateString,
                                                          @"summary" : @(1) }
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  MetricData *metricData = [[mappingResult array] objectAtIndex:0];
                                                  NSMutableDictionary *values = [self.appViewMetricValues objectForKey:key];
                                                  [values setValue:metricData.metricValue forKey:@"week"];
                                                  
                                                  [self.collectionView reloadData];
                                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"error: %@", error);
                                              }];
    }];

}

#pragma mark -
#pragma mark Observers

- (void) appHasGoneInBackground {
//    self.appViewMetricValues = [NSMutableDictionary dictionary];
}

- (void) appDidBecomeActive {
//    NSLog(@"appDidBecomeActive: %@", self.appViewMetrics);
    self.appView = [AppView findFirst];
//    [self.collectionView reloadData];
    [self loadPerformanceData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"settingsSegue"]) {
        SettingsViewController *vc = [segue destinationViewController];
        vc.delegate = self;
    }
}

@end
