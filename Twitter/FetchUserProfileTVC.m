//
//  FetchUserProfileTVC.m
//  Twitter
//
//  Created by nitesh.vi on 24/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "FetchUserProfileTVC.h"
#import <TwitterKit/TwitterKit.h>
#import "TwitterFetcher.h"

#define userTimelineEndPoint @"https://api.twitter.com/1.1/statuses/user_timeline.json"
#define COUNT_OF_TWEETS_TO_RETRIEVE @"20"

@interface FetchUserProfileTVC ()
@end

@implementation FetchUserProfileTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchUserProfileTweets];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchUserProfileTweets {
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    NSDictionary *params = @{@"id" : self.userID , @"count" : COUNT_OF_TWEETS_TO_RETRIEVE};
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:userTimelineEndPoint parameters:params error:&clientError];
    
    if (request) {
        dispatch_queue_t fetchFollowingListQ = dispatch_queue_create("Following List Fetcher", NULL);
        dispatch_async(fetchFollowingListQ, ^{
            [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (data) {
                    NSError *jsonError;
                    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                    //NSLog(@"%@", json);
                    self.tweetsList = [[NSMutableArray alloc] init];
                    [self.tweetsList addObjectsFromArray:json];
                    [self.refreshControl endRefreshing];
                    [self.tableView reloadData];
                    
                }
                else {
                    NSLog(@"Error: %@", connectionError);
                }
            }];
        });
    }
    else {
        NSLog(@"Error: %@", clientError);
    }
    
}

@end
