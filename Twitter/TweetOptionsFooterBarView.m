//
//  TweetOptionsFooterBarView.m
//  
//
//  Created by nitesh.vi on 31/08/17.
//
//

#import "TweetOptionsFooterBarView.h"
#import "TwitterTweet.h"

@implementation TweetOptionsFooterBarView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

// Animation properties

static float animationTime = 0.1;
static float likeIconAnimationSmallSizePercent = 0.75;
static float HALF_PERCENT = 0.5;


- (IBAction)likeButtonPressed:(UIButton *)sender {
    if (sender.tag == 0) {
        [TwitterTweet likeTweetWithId:sender.restorationIdentifier];
        sender.tag = 1;
        __block CGPoint origin = self.likeIconImageView.frame.origin;
        __block CGFloat length = self.likeIconImageView.frame.size.height;
        [UIView animateWithDuration:animationTime animations:^{
            CGFloat newOrigin = (1-likeIconAnimationSmallSizePercent)*length*HALF_PERCENT;
            self.likeIconImageView.frame = CGRectMake(newOrigin, newOrigin, likeIconAnimationSmallSizePercent*length, likeIconAnimationSmallSizePercent*length) ;
        } completion:^(BOOL finished) {
            self.likeIconImageView.image = [UIImage imageNamed:@"liked_icon"];
            self.likeCountLabel.text = [NSString stringWithFormat:@"%lld",[self.likeCountLabel.text longLongValue] + 1];
            self.likeCountLabel.textColor = [UIColor redColor];
            [UIView animateWithDuration:animationTime animations:^{
                self.likeIconImageView.frame = CGRectMake(origin.x, origin.y, length, length);
            }];
        }];
    }
    else {
        [TwitterTweet unlikeTweetWithId:sender.restorationIdentifier];
        sender.tag = 0;
        __block CGPoint origin = self.likeIconImageView.frame.origin;
        __block CGFloat length = self.likeIconImageView.frame.size.height;
        [UIView animateWithDuration:animationTime animations:^{
            CGFloat newOrigin = (1-likeIconAnimationSmallSizePercent)*length*HALF_PERCENT;
            self.likeIconImageView.frame = CGRectMake(newOrigin, newOrigin, likeIconAnimationSmallSizePercent*length, likeIconAnimationSmallSizePercent*length) ;
        }completion:^(BOOL finished) {
            self.likeIconImageView.image = [UIImage imageNamed:@"like_icon"];
            self.likeCountLabel.text = [NSString stringWithFormat:@"%lld",[self.likeCountLabel.text longLongValue] - 1];
            self.likeCountLabel.textColor = [UIColor blackColor];
            [UIView animateWithDuration:animationTime animations:^{
                self.likeIconImageView.frame = CGRectMake(origin.x, origin.y, length, length);
            }];
        }];
    }
}
- (IBAction)retweetButtonPressed:(UIButton *)sender {
    if (sender.tag == 0) {
        [TwitterTweet retweetTweetWithId:sender.restorationIdentifier];
        sender.tag = 1;
        self.retweetIconImageView.image = [UIImage imageNamed:@"retweeted_icon"];
        self.retweetCountLabel.text = [NSString stringWithFormat:@"%lld",[self.retweetCountLabel.text longLongValue] + 1];
        self.retweetCountLabel.textColor = [UIColor greenColor];
    }
    else {
        [TwitterTweet unretweetTweetWithId:sender.restorationIdentifier];
        sender.tag = 0;
        self.retweetIconImageView.image = [UIImage imageNamed:@"retweet_icon"];
        self.retweetCountLabel.text = [NSString stringWithFormat:@"%lld",[self.retweetCountLabel.text longLongValue] - 1];
        self.retweetCountLabel.textColor = [UIColor blackColor];
    }
}

@end
