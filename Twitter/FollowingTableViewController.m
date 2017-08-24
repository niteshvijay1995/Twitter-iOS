//
//  FollowingTableViewController.m
//  Twitter
//
//  Created by nitesh.vi on 23/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "FollowingTableViewController.h"
#import "CustomUserDetailCell.h"
#import "UserProfileTableViewController.h"
#import "FetchUserProfileTVC.h"

@interface FollowingTableViewController ()

@end

@implementation FollowingTableViewController

- (void)setFollowingList:(NSMutableArray *)followingList {
    _followingList = followingList;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshFollowingList) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.followingList)
    {
        return [self.followingList count];
    }
    else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"UserDetailCell";
    CustomUserDetailCell *cell = (CustomUserDetailCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *user = self.followingList[indexPath.row];
    [cell configureCellUsingUser:user];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[CustomUserDetailCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if(indexPath) {
            if([segue.identifier isEqualToString:@"showUserDetail"]) {
                if ([segue.destinationViewController isKindOfClass:[FetchUserProfileTVC class]]) {
                    UserProfileTableViewController *upTVC = (UserProfileTableViewController *)segue.destinationViewController;
                    upTVC.userID = [NSString stringWithFormat:@"%@",[self.followingList[indexPath.row] valueForKey:@"id"]];
                    
                }
            }
        }
    }
    
}

@end
