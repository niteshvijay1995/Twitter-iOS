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
#import "UserProfileZeroCVCell.h"
#import "AppDelegate.h"
#import "ImageCache.h"
#import "DownloaderQueue.h"

@interface MyProfileTweetsCollectionViewController ()

@property (strong, nonatomic) NSMutableArray *tweetList;

@end

@implementation MyProfileTweetsCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self disableRefreshControl];
    [self fetchNewTweets];
    [self.collectionView registerNib:[UINib nibWithNibName:@"UserProfileCellZero" bundle:NULL] forCellWithReuseIdentifier:@"UserCellZero"];
    if (!self.user) {
        self.user = ((AppDelegate *)[[UIApplication sharedApplication]delegate]).meUser;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.tweetList count] + 1;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        UserProfileZeroCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCellZero" forIndexPath:indexPath];
        [self configureUserZeroCell:cell];
        return cell;
    }
    else {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:indexPath.item-1 inSection:indexPath.section];
        return [super collectionView:collectionView cellForItemAtIndexPath:newIndexPath];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, 150);
    }
    else {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:indexPath.item-1 inSection:indexPath.section];
        return [super collectionView:collectionView
                              layout:collectionViewLayout
              sizeForItemAtIndexPath:newIndexPath];
    }
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
                    NSMutableArray *newTweetDictionaryList = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                    self.tweetList = [Tweet loadTweetFromTweetsArray:newTweetDictionaryList];
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

- (void)configureImageView:(UIImageView *)imageView byImageFromUrl:(NSString *)imageUrl {
    UIImage *image = [[ImageCache sharedInstance] getCachedImageForKey:imageUrl];
    if (image) {
        imageView.image = image;
    }
    else {
        [[DownloaderQueue sharedInstance].getImageDownloaderQueue addOperationWithBlock:^{
            NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:imageUrl]];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (image) {
                    [[ImageCache sharedInstance] cacheImage:image forKey:imageUrl];
                    imageView.image = image;
                }
            }];
        }];
    }
}

- (void)configureUserZeroCell:(UserProfileZeroCVCell *)cell {
    cell.profileImageView.clipsToBounds = YES;
    cell.profileImageView.layer.cornerRadius = cell.profileImageView.bounds.size.height/2;
    
    self.navigationController.navigationBar.backgroundColor = cell.profileBackgroundImageView.backgroundColor;
    self.navigationController.navigationBar.alpha = 1;
    
    cell.userFullName.text = self.user.fullName;
    cell.userHandle.text = self.user.screenName;
    [self configureImageView:cell.profileImageView byImageFromUrl:self.user.profileImageUrl];
}

@end
