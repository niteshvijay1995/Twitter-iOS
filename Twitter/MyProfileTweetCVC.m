//
//  MyProfileTweetCVC.m
//  Twitter
//
//  Created by nitesh.vi on 18/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "MyProfileTweetCVC.h"
#import "AppDelegate.h"

@implementation MyProfileTweetCVC

- (void)viewDidLoad {
    self.user = ((AppDelegate *)[UIApplication sharedApplication].delegate).meUser;
    [super viewDidLoad];
}

@end
