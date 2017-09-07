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
#import "TwitterUser.h"

@interface HomeScreenTweetFetcherCVC ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *profileButton;

@end

@implementation HomeScreenTweetFetcherCVC

static NSString *maxTweetCountToFetch = @"40";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setProfileImage];
    [self fetchTweets];
    // Do any additional setup after loading the view.
}

- (void)setProfileImage {
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    NSString *userID = store.session.userID;
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    NSDictionary *params = @{@"user_id":userID};
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:usersEndPoint parameters:params error:&clientError];
    
    if (request) {
        dispatch_queue_t fetchUserInfoQ = dispatch_queue_create("User Info Fetcher", NULL);
        dispatch_async(fetchUserInfoQ, ^{
            [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (data) {
                    NSError *jsonError;
                    NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                    NSURL *profileImageUrl = [TwitterUser getProfileImageUrlForUser:userInfo];
                    NSData * imageData = [[NSData alloc] initWithContentsOfURL:profileImageUrl];
                    UIImage *profileImage = [UIImage imageWithData:imageData];
                    profileImage = [profileImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    UIButton *imageButton = [[UIButton alloc] init];
                    imageButton.frame = CGRectMake(0, 0,32, 32);
                    [imageButton setImage:profileImage forState:UIControlStateNormal];
                    imageButton.layer.masksToBounds = YES;
                    imageButton.clipsToBounds = YES;
                    imageButton.layer.cornerRadius = 0.5 * imageButton.bounds.size.height;
                    self.profileButton.customView = imageButton;
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
                    [self.refreshControl endRefreshing];
                }
            }];
        });
    }
    else {
        NSLog(@"Error: %@", clientError);
        [self.refreshControl endRefreshing];
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
                    [self.refreshControl endRefreshing];
                }
            }];
        });
    }
    else {
        NSLog(@"Error: %@", clientError);
        [self.refreshControl endRefreshing];
    }
}

- (void)fetchMoreData {
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    NSString *userID = store.session.userID;
    
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    
    NSString *max_id = [NSString stringWithFormat:@"%lld",[[TwitterTweet getTweetIDForTweet:[self.tweetList lastObject]] longLongValue] - 1];
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
    @synchronized(self) {
        int scrollDiffValue = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
        NSLog(@"%d",[TwitterFetcher getFetchTweetWaitingFlag]);
        NSLog(@"%d",scrollDiffValue);
        if (scrollDiffValue <= 5.0 && ![TwitterFetcher getFetchTweetWaitingFlag] && [self.tweetList count]!=0) {
            NSLog(@"Fetching more data");
            [TwitterFetcher setFetchTweetWaitingFlagTo:YES];
            [self fetchMoreData];
        }
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
