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
#import "TwitterTweet.h"

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
    if (self.tweetList == nil || [self.tweetList count] == 0) {
        [self fetchTweets];
    }
    else {
        [self fetchNewTweets];
    }
}

- (void)fetchNewTweets {
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    NSString *userID = store.session.userID;
    
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    
    NSString *since_id = [TwitterTweet getTweetIDForTweet:[self.tweetList firstObject]];
    NSDictionary *params = @{@"count":maxTweetCountToFetch, @"since_id":since_id};
    
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:homeTimelineEndPoint parameters:params error:&clientError];
    
    if (request) {
        dispatch_queue_t fetchHomeScreenTweetQ = dispatch_queue_create("Home Screen Tweet Fetcher", NULL);
        dispatch_async(fetchHomeScreenTweetQ, ^{
            [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (data) {
                    NSError *jsonError;
                    NSMutableArray *newTweetList = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                    self.tweetList = [[newTweetList arrayByAddingObjectsFromArray:self.tweetList] mutableCopy];
                    [self.refreshControl endRefreshing];
                    [self.collectionView reloadData];
                    [self.collectionViewLayout invalidateLayout];
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

- (void)fetchTweets {
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    NSString *userID = store.session.userID;
    
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    
    NSDictionary *params = @{@"count":maxTweetCountToFetch};
    
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:homeTimelineEndPoint parameters:params error:&clientError];
    
    if (request) {
        dispatch_queue_t fetchHomeScreenTweetQ = dispatch_queue_create("Home Screen Tweet Fetcher", NULL);
        dispatch_async(fetchHomeScreenTweetQ, ^{
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

- (void)fetchMoreData {
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    NSString *userID = store.session.userID;
    
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    
    NSString *max_id = [NSString stringWithFormat:@"%d",[[TwitterTweet getTweetIDForTweet:[self.tweetList lastObject]] intValue] - 1];
    NSDictionary *params = @{@"count":maxTweetCountToFetch, @"max_id":max_id};
    
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:homeTimelineEndPoint parameters:params error:&clientError];
    
    if (request) {
        dispatch_queue_t fetchHomeScreenTweetQ = dispatch_queue_create("Home Screen Tweet Fetcher", NULL);
        dispatch_async(fetchHomeScreenTweetQ, ^{
            [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (data) {
                    NSError *jsonError;
                    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                    //NSLog(@"%@", json);
                    [self.tweetList addObjectsFromArray:json];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.refreshControl endRefreshing];
                        [self.collectionView reloadData];
                        [TwitterFetcher setFetchTweetWaitingFlagTo:NO];
                    });
                }
                else {
                    NSLog(@"Error: %@", connectionError);
                    [TwitterFetcher setFetchTweetWaitingFlagTo:NO];
                }
            }];
        });
    }
    else {
        NSLog(@"Error: %@", clientError);
        [TwitterFetcher setFetchTweetWaitingFlagTo:NO];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int scrollDiffValue = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
    if (scrollDiffValue <= 5.0 && ![TwitterFetcher getFetchTweetWaitingFlag]) {
        [TwitterFetcher setFetchTweetWaitingFlagTo:YES];
        [self fetchMoreData];
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
