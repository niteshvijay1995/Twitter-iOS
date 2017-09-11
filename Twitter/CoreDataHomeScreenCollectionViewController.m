//
//  CoreDataHomeScreenCollectionViewController.m
//  Twitter
//
//  Created by nitesh.vi on 06/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "CoreDataHomeScreenCollectionViewController.h"
#import "NewTweetView.h"
#import "Tweet+CoreDataProperties.h"
#import "TweetCollectionViewCell.h"
#import "TwitterFetcher.h"

@interface CoreDataHomeScreenCollectionViewController () <UICollectionViewDelegate>

@property (strong, nonatomic) NSBlockOperation *blockOperation;
@property BOOL shouldReloadCollectionView;
@property (strong, nonatomic) NSCache *cellSizeCache;       // cell size for a tweet(id)
@end

@implementation CoreDataHomeScreenCollectionViewController

static NSString * const reuseIdentifier = @"TweetCell";

- (NSCache *)cellSizeCache {
    if (!_cellSizeCache) {
        _cellSizeCache = [[NSCache alloc] init];
    }
    return _cellSizeCache;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:NULL] forCellWithReuseIdentifier:reuseIdentifier];
    //((UICollectionViewFlowLayout *)self.collectionViewLayout).estimatedItemSize = CGSizeMake(1, 1);
    
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

#pragma mark - CoreData

- (void)performFetch {
    if (self.fetchedResultsController) {
        if (self.fetchedResultsController.fetchRequest.predicate) {
            if (self.debug) NSLog(@"[%@ %@] fetching %@ with predicate: %@", NSStringFromClass([self class]),
                                  NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName, self.fetchedResultsController.fetchRequest.predicate);
        } else {
            if (self.debug) NSLog(@"[%@ %@] fetching all %@ (i.e., no predicate)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName);
        }
        NSError *error;
        BOOL success = [self.fetchedResultsController performFetch:&error];
        if (!success) NSLog(@"[%@ %@] performFetch: failed", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        if (error) NSLog(@"%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
        NSLog(@"fetchedResultsController found %d objects", (int)[self.fetchedResultsController.fetchedObjects count]);
    } else {
        if (self.debug) NSLog(@"[%@ %@] no NSFetchedResultsController (yet?)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
    //[self.collectionView reloadData];
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)newfrc {
    NSFetchedResultsController *oldfrc = _fetchedResultsController;
    if (newfrc != oldfrc) {
        _fetchedResultsController = newfrc;
        newfrc.delegate = self;
        if ((!self.title || [self.title isEqualToString:oldfrc.fetchRequest.entity.name]) && (!self.navigationController || !self.navigationItem.title)) {
            self.title = newfrc.fetchRequest.entity.name;
        }
        if (newfrc) {
            if (self.debug) NSLog(@"[%@ %@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), oldfrc ? @"updated" : @"set");
            [self performFetch];
        } else {
            if (self.debug) NSLog(@"[%@ %@] reset to nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            [self.collectionView reloadData];
        }
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger sections = [[self.fetchedResultsController sections] count];
    return sections;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger items = 0;
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        items = [sectionInfo numberOfObjects];
    }
    return items;
}

#pragma mark <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    id size = [self.cellSizeCache objectForKey:tweet.id];
    if (size) {
        return [size CGSizeValue];
    }
    TweetCollectionViewCell *dummyCell = [[NSBundle mainBundle] loadNibNamed:@"TweetCell" owner:self options:nil].firstObject;
    [dummyCell configureStaticCellFromCoreDataTweet:tweet];
    CGSize contraintSize = CGSizeMake(self.collectionView.bounds.size.width - self.collectionView.contentInset.left - self.collectionView.contentInset.right, CGFLOAT_MAX);
    CGSize resSize = [dummyCell systemLayoutSizeFittingSize:contraintSize];
    [self.cellSizeCache setObject:[NSValue valueWithCGSize:resSize] forKey:tweet.id];
    NSLog(@"%f %f",resSize.width, resSize.height);
    return resSize;
}

#pragma mark - <NSFetchedResultsControllerDelegate>

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.shouldReloadCollectionView = NO;
    self.blockOperation = [[NSBlockOperation alloc] init];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(nonnull id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    __weak UICollectionView *collectionView = self.collectionView;
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            break;
        }
            
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    __weak UICollectionView *collectionView = self.collectionView;
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            if ([self.collectionView numberOfSections] > 0) {
                if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                    self.shouldReloadCollectionView = YES;
                } else {
                    [self.blockOperation addExecutionBlock:^{
                        [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
                    }];
                }
            } else {
                self.shouldReloadCollectionView = YES;
            }
            break;
        }
            
        case NSFetchedResultsChangeDelete: {
            if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                self.shouldReloadCollectionView = YES;
            } else {
                [self.blockOperation addExecutionBlock:^{
                    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
                }];
            }
            break;
        }
            
        case NSFetchedResultsChangeUpdate: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
            break;
        }
            
        case NSFetchedResultsChangeMove: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
            }];
            break;
        }
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.shouldReloadCollectionView) {
        [self.collectionView reloadData];
    } else {
        [self.collectionView performBatchUpdates:^{
            [self.blockOperation start];
        } completion:nil];
    }
}

#pragma mark <UICollectionViewDelegateFlowLayout>

- (IBAction)composeTweet:(id)sender {
    NewTweetView *newTweetViewController = [[NewTweetView alloc] init];
    [self presentViewController:newTweetViewController animated:YES completion:nil];
}

@end
