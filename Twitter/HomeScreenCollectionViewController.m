//
//  HomeScreenCollectionViewController.m
//  Twitter
//
//  Created by nitesh.vi on 23/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "HomeScreenCollectionViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "NavigationHelper.h"
#import "TweetCollectionViewCell.h"
#import "TwitterFetcher.h"

@interface HomeScreenCollectionViewController ()
@property (strong, nonatomic) TweetCollectionViewCell  *staticTweetCell;
@property (strong, nonatomic) NSCache *cellSizeCache;
@end

@implementation HomeScreenCollectionViewController

- (NSMutableArray *)tweetList {
    if (!_tweetList) {
        _tweetList = [[NSMutableArray alloc] init];
    }
    return _tweetList;
}

- (TweetCollectionViewCell *)staticTweetCell {
    if (!_staticTweetCell) {
        _staticTweetCell = (TweetCollectionViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"TweetCell" owner:self options:nil] firstObject];
    }
    return _staticTweetCell;
}

- (NSCache *)cellSizeCache {
    if(!_cellSizeCache) {
        _cellSizeCache = [[NSCache alloc] init];
    }
    return _cellSizeCache;
}

static NSString * const reuseIdentifier = @"TweetCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:NULL] forCellWithReuseIdentifier:reuseIdentifier];
    
    ((UICollectionViewFlowLayout *)self.collectionViewLayout).estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = twitterBlueColor;
    [self.refreshControl addTarget:self action:@selector(refreshHomeScreen) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.tweetList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TweetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSDictionary *tweet = self.tweetList[indexPath.row];
    [cell configureCellFromTweet:tweet];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}*/


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.bounds.size.width-10, 1);
}


- (IBAction)logout:(UIBarButtonItem *)sender {
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    NSString *userID = store.session.userID;
    [store logOutUserID:userID];
    [NavigationHelper navigateToLoginView];
}

@end
