//
//  TweetCollectionViewCell.h
//  Twitter
//
//  Created by nitesh.vi on 28/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tweetCellViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *tweetCellView;

- (void)configureCellFromTweet:(NSDictionary *)tweet;

@end
