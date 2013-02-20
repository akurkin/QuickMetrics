//
//  ApplicationsViewController.h
//  Quick Metrics
//
//  Created by Alex Kurkin on 2/11/13.
//  Copyright (c) 2013 Brilliant Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "User.h"
#import "AppView.h"

@interface ApplicationsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *applicationsTableView;

@end
