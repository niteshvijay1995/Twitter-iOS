//
//  TweetsCollectionViewController.m
//  Twitter
//
//  Created by nitesh.vi on 13/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "TweetsCollectionViewController.h"
#import "TwitterFetcher.h"
#import "TweetCollectionViewCell.h"
#import "Tweet+TwitterTweetParser.h"
#import "NVTweet.h"

@interface TweetsCollectionViewController ()

@property (strong, nonatomic) NSCache *portraitCellSizeCache;       // cell size for a tweet(id)
@property (strong, nonatomic) NSCache *landscapeCellSizeCache;

@end

@implementation TweetsCollectionViewController

static NSString * const reuseIdentifier = @"TweetCell";

- (NSCache *)portraitCellSizeCache {
    if (!_portraitCellSizeCache) {
        _portraitCellSizeCache = [[NSCache alloc] init];
    }
    return _portraitCellSizeCache;
}

- (NSCache *)landscapeCellSizeCache {
    if (!_landscapeCellSizeCache) {
        _landscapeCellSizeCache = [[NSCache alloc] init];
    }
    return _landscapeCellSizeCache;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:NULL] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = twitterBlueColor;
    [self.refreshControl addTarget:self action:@selector(startRefresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
}

- (void)startRefresh {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void)disableRefreshControl {
    [self.refreshControl removeFromSuperview];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return 0;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TweetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSObject<NVTweet> *nvTweet = [self getTweetForIndexPath:indexPath];
    [cell configureCellFromCoreDataTweet:nvTweet];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSObject<NVTweet> *tweet = [self getTweetForIndexPath:indexPath];
    id size;
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        size = [self.portraitCellSizeCache objectForKey:tweet.id];
    }
    else {
        size = [self.landscapeCellSizeCache objectForKey:tweet.id];
    }
    if (size) {
        return [size CGSizeValue];
    }
    TweetCollectionViewCell *dummyCell = [[NSBundle mainBundle] loadNibNamed:@"TweetCell" owner:self options:nil].firstObject;
    [dummyCell configureStaticCellFromCoreDataTweet:tweet];
    CGSize contraintSize = CGSizeMake(self.collectionView.bounds.size.width - self.collectionView.contentInset.left - self.collectionView.contentInset.right, CGFLOAT_MAX);
    CGSize resSize = [dummyCell systemLayoutSizeFittingSize:contraintSize];
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        [self.portraitCellSizeCache setObject:[NSValue valueWithCGSize:resSize] forKey:tweet.id];
    }
    else {
        [self.landscapeCellSizeCache setObject:[NSValue valueWithCGSize:resSize] forKey:tweet.id];
    }
    NSLog(@"%f %f",resSize.width, resSize.height);
    return resSize;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.item == [self collectionView:self.collectionView numberOfItemsInSection:0] - 1) {
        NSLog(@"Fetching More Data");
        [self fetchMoreTweets];
    }
}

#pragma mark - Abstract methods
- (NSObject<NVTweet> *)getTweetForIndexPath:(NSIndexPath *)indexPath {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return nil;
}

- (void)fetchMoreTweets {
    // Override in subclass to fetch more tweets on reaching end.
    // setFetchTweetWaitingFlagTo No on completed
}

@end
