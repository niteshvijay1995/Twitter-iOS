//
//  MyProfileTweetsCollectionViewController.m
//  Twitter
//
//  Created by nitesh.vi on 14/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "MyProfileTweetsCollectionViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "TwitterFetcher.h"
#import "Tweet+TwitterTweetParser.h"

@interface MyProfileTweetsCollectionViewController ()

@property (strong, nonatomic) NSMutableArray *tweetList;

@end

@implementation MyProfileTweetsCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self disableRefreshControl];
    [self fetchNewTweets];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.tweetList count];
    
}

- (Tweet *)getTweetForIndexPath:(NSIndexPath *)indexPath {
    return [self.tweetList objectAtIndex:indexPath.item];
}

- (void)fetchNewTweets {
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    NSString *userID = store.session.userID;
    
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    NSDictionary *params = @{@"id":userID};
    
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:userTimelineEndPoint parameters:params error:&clientError];
    
    if (request) {
        dispatch_queue_t fetchHomeScreenTweetQ = dispatch_queue_create("Home Screen Tweet Fetcher", NULL);
        dispatch_async(fetchHomeScreenTweetQ, ^{
            [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (data) {
                    NSError *jsonError;
                    NSMutableArray *newTweetDictionaryList = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];                }
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

@end
