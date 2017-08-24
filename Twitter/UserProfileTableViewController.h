//
//  UserProfileTableViewController.h
//  Twitter
//
//  Created by nitesh.vi on 24/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileTableViewController : UITableViewController
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSMutableArray *tweetsList;
@end
