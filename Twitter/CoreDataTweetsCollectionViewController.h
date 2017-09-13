//
//  CoreDataHomeScreenCollectionViewController.h
//  Twitter
//
//  Created by nitesh.vi on 06/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CoreDataTweetsCollectionViewController : UICollectionViewController

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)performFetch;

@property BOOL debug;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end
