//
//  TweetsCDHSCVC.m
//  Twitter
//
//  Created by nitesh.vi on 07/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "TweetsCDHSCVC.h"
#import "Tweet+CoreDataClass.h"
#import "TweetCollectionViewCell.h"
#import <TwitterKit/TwitterKit.h>
#import "TwitterFetcher.h"
#import "TwitterTweet.h"
#import "TwitterUser.h"
#import "CoreDataController.h"
#import "AppDelegate.h"
#import "Me+MeParser.h"

#define maxTweetCountToFetch @"200"

@interface TweetsCDHSCVC()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *profileImageButton;

@end

@implementation TweetsCDHSCVC

- (void)awakeFromNib {
    [super awakeFromNib];

    self.debug = YES;
    self.managedObjectContext = [CoreDataController sharedInstance].managedObjectContext;
    
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(startHomeTimelineFetch:) userInfo:nil repeats:YES];
    [self startHomeTimelineFetch];
    
    [self setProfileImage];
}

- (void)setProfileImage {
    Me *meUser = ((AppDelegate *)[UIApplication sharedApplication].delegate).meUser;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    //request.fetchLimit = 30;
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO selector:@selector(localizedStandardCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

static NSString * const reuseIdentifier = @"TweetCell";

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TweetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];

    [cell configureCellFromCoreDataTweet:tweet];
    return cell;
}

- (void)startHomeTimelineFetch:(NSTimer *)timer {
    [self startHomeTimelineFetch];
}

- (void)refreshHomeScreen {
    if (!self.refreshControl.refreshing) {
        [self startHomeTimelineFetch];
    }
}

- (void)startHomeTimelineFetch {
    NSLog(@"Fetching Tweets");
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    NSString *userID = store.session.userID;

    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    
    NSDictionary *params = @{@"count":maxTweetCountToFetch};
    
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:homeTimelineEndPoint parameters:params error:&clientError];
    
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                NSManagedObjectContext *context = [CoreDataController sharedInstance].managedObjectContext;
                if (context) {
                    NSError *jsonError;
                    NSArray *tweets = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                    [context performBlock:^{
                        [Tweet laodTweetsFromTweetArray:tweets intoManagedObjectContext:context];
                        [context save:NULL];
                    }];
                    [self.refreshControl endRefreshing];
                }
            }
            else {
                NSLog(@"Error: %@", connectionError);
                [self.refreshControl endRefreshing];
            }
        }];
    }
    else {
        NSLog(@"Error: %@", clientError);
        [self.refreshControl endRefreshing];
    }
}


@end
