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
#import "TweetDatabaseAvailability.h"

@implementation TweetsCDHSCVC

- (void)awakeFromNib {
    [super awakeFromNib];

    ((UICollectionViewFlowLayout *)self.collectionViewLayout).estimatedItemSize = CGSizeMake(1, 1);
    [[NSNotificationCenter defaultCenter] addObserverForName:TweetDatabaseAvailabilityNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        self.managedObjectContext = note.userInfo[TweetDatabaseAvailabilityContext];
    }];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
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

@end
