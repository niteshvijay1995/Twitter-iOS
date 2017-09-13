//
//  TweetsCollectionViewController.h
//  Twitter
//
//  Created by nitesh.vi on 13/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet+TwitterTweetParser.h"

@interface TweetsCollectionViewController : UICollectionViewController

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end
