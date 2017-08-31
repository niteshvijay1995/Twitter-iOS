//
//  HomeScreenTweetFetcherCVC.m
//  Twitter
//
//  Created by nitesh.vi on 29/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "HomeScreenTweetFetcherCVC.h"
#import <TwitterKit/TwitterKit.h>
#import "TwitterFetcher.h"

@interface HomeScreenTweetFetcherCVC ()

@end

@implementation HomeScreenTweetFetcherCVC

static NSString *maxTweetCountToFetch = @"40";
static NSString *homeTimelineEndPoint = @"https://api.twitter.com/1.1/statuses/home_timeline.json";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchTweets];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshHomeScreen {
    [self fetchTweets];
}

- (void)fetchTweets {
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    NSString *userID = store.session.userID;
    
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    
    NSDictionary *params = @{@"count":maxTweetCountToFetch};
    
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:homeTimelineEndPoint parameters:params error:&clientError];
    
    if (request) {
        dispatch_queue_t fetchFollowingListQ = dispatch_queue_create("Following List Fetcher", NULL);
        dispatch_async(fetchFollowingListQ, ^{
            [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (data) {
                    NSError *jsonError;
                    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                    //NSLog(@"%@", json);
                    self.tweetList = [[NSMutableArray alloc] init];
                    [self.tweetList addObjectsFromArray:json];
                    [self.refreshControl endRefreshing];
                    [self.collectionView reloadData];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
