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
- (IBAction)likeButtonPressed:(UIButton *)sender {
    if (sender.tag == 0) {
        [TwitterTweet likeTweetWithId:sender.restorationIdentifier];
        sender.tag = 1;
        self.likeIconImageView.image = [UIImage imageNamed:@"liked_icon"];
        self.likeCountLabel.text = [NSString stringWithFormat:@"%lld",[self.likeCountLabel.text longLongValue] + 1];
        self.likeCountLabel.textColor = [UIColor redColor];

        
    }
    else {
        [TwitterTweet unlikeTweetWithId:sender.restorationIdentifier];
        sender.tag = 0;
        self.likeIconImageView.image = [UIImage imageNamed:@"like_icon"];
        self.likeCountLabel.text = [NSString stringWithFormat:@"%lld",[self.likeCountLabel.text longLongValue] - 1];
        self.likeCountLabel.textColor = [UIColor blackColor];
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
