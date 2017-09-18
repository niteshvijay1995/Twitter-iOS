//
//  CoreDataHomeScreenCollectionViewController.h
//  Twitter
//
//  Created by nitesh.vi on 06/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "TweetsCollectionViewController.h"

@interface CoreDataTweetsCollectionViewController : TweetsCollectionViewController

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)performFetch;

@property BOOL debug;

@end
