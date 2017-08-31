//
//  TweetOptionsFooterBarView.h
//  
//
//  Created by nitesh.vi on 31/08/17.
//
//

#import <UIKit/UIKit.h>

@interface TweetOptionsFooterBarView : UIView
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;

@end
