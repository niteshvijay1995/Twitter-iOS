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
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *likeIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *retweetIconImageView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@end
