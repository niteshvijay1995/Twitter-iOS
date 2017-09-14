//
//  SearchViewController.m
//  Twitter
//
//  Created by nitesh.vi on 11/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "SearchViewController.h"
#import "HomeScreenCDTCVC.h"
#import "CoreDataController.h"
#import "TweetCollectionViewCell.h"
#import "CoreDataTweetsCollectionViewController.h"

@interface SearchViewController() <UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSManagedObjectContext *tweeteManagedObjectContext;
@property (nonatomic, strong) NSFetchRequest *request;
@property (nonatomic, strong) CoreDataTweetsCollectionViewController *searchResultsCVC;
@end

@implementation SearchViewController

static NSString * const reuseIdentifier = @"TweetCell";

- (NSManagedObjectContext *)tweeteManagedObjectContext {
    if (!_tweeteManagedObjectContext) {
        _tweeteManagedObjectContext = [CoreDataController sharedInstance].managedObjectContext;
    }
    return _tweeteManagedObjectContext;
}

- (NSFetchRequest *)request {
    if (!_request) {
        _request = [[NSFetchRequest alloc] initWithEntityName:@"Tweet"];
        _request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO selector:@selector(localizedStandardCompare:)]];
    }
    return _request;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar.delegate = self;
    self.searchResultsCVC = [[self childViewControllers] firstObject];
    [self.searchResultsCVC disableRefreshControl];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"Text changed - %@",searchText);
    NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"userFullName BEGINSWITH[c] %@",searchText];
    NSPredicate *secondNamePredicate = [NSPredicate predicateWithFormat:@"userFullName contains[c] %@",[@" " stringByAppendingString:searchText]];
    self.request.predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[namePredicate, secondNamePredicate]];
    if ([searchText isEqualToString:@""]) {
        self.request.predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[namePredicate]];
    }
    self.searchResultsCVC.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: self.request managedObjectContext:self.tweeteManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

- (IBAction)tapToDisableKeyboard:(id)sender {
    [self.view endEditing:YES];
}




@end
