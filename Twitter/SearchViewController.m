//
//  SearchViewController.m
//  Twitter
//
//  Created by nitesh.vi on 11/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController() <UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation SearchViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar.delegate = self;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"Text changed - %@",searchText);
}

@end
