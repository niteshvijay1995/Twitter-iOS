//
//  UserProfileTweetTableViewCell.m
//  Twitter
//
//  Created by nitesh.vi on 25/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "UserProfileTweetTableViewCell.h"
#import <TwitterKit/TwitterKit.h>
#import "TwitterFetcher.h"
#import "TwitterUser.h"
#import "ImageCache.h"

@interface UserProfileTweetTableViewCell()
@property (strong, nonatomic) UIImageView *userProfileImageView;
@property (strong, nonatomic) UILabel *userFullNameLabel;
@property (strong, nonatomic) UILabel *tweetTextLabel;
@property (strong, nonatomic) NSURL *profileImageUrl;
@property (weak, nonatomic) IBOutlet UILabel *tweetTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;

@end

@implementation UserProfileTweetTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)configureProfileImageFromUrl:(NSURL *)profileImageUrl {
    self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.height/2;
    self.userProfileImage.clipsToBounds = YES;
    
    UIImage *profileImage = [[ImageCache sharedInstance] getCachedImageForKey:profileImageUrl.absoluteString];
    if (profileImage) {
        self.userProfileImage.image = profileImage;
    }
    else {
        self.userProfileImage.image = [UIImage imageNamed:@"default_profile_normal"];
        dispatch_queue_t imageFetchQ = dispatch_queue_create("profile image fetcher", NULL);
        dispatch_async(imageFetchQ, ^{
            NSData * imageData = [[NSData alloc] initWithContentsOfURL: profileImageUrl];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[ImageCache sharedInstance] cacheImage:image forKey:profileImageUrl.absoluteString];
                if ([profileImageUrl isEqual:self.profileImageUrl]) {
                    self.userProfileImage.image = image;
                }
            });
        });
    }
}

- (void)configureRetweetButtonForRetweetStatus:(BOOL)retweetStatus retweetCount:(NSString *)retweetCount {
    self.retweetCountLabel.text = retweetCount;
    if (retweetStatus) {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweeted_icon"] forState:UIControlStateNormal];
        self.retweetButton.tag = 1;
        self.retweetCountLabel.textColor = [UIColor greenColor];
    }
    else {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_icon"] forState:UIControlStateNormal];
        self.retweetButton.tag = 0;
        self.retweetCountLabel.textColor = [UIColor blackColor];
    }
    [self setNeedsLayout];
}

- (BOOL)isRetweetTweet:(NSDictionary *)tweet {
    if ([tweet valueForKey:TWITTER_TWEET_RETWEET_STATUS]) {
        return YES;
    }
    return NO;
}

- (void)configureCellForRetweet:(NSDictionary *)tweet {
    NSDictionary *user;
    user = [tweet valueForKeyPath:TWITTER_TWEET_USER];
    self.retweetLabel.text = [[user valueForKeyPath:TWITTER_USER_FULL_NAME] stringByAppendingString:@" retweeted"];
    
    self.retweetIconImageView.image = [UIImage imageNamed:@"retweet_icon"];
    
    self.userFullNameTopRetweetLabelContraint.priority = 750;
    self.userFullNameLabelTopMarginContraint.priority = 250;
    
    self.userProfileImageTopRetweetLabelContraint.priority = 750;
    self.userProfileImageTopMarginConstraint.priority = 250;
    
    [self setNeedsUpdateConstraints];
    [self.superview layoutIfNeeded];
    
}

- (void)addToCellTime:(NSString *)time {
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"EEEE MMM dd HH:mm:ss Z yyyy"];
    NSDate *tweetDate = [dateFormatter dateFromString:time];
    [dateFormatter setDateFormat:@"dd MMM YY"];
    self.tweetTimeLabel.text = [dateFormatter stringFromDate:tweetDate];
}

- (void)configureCellUsingTweet:(NSDictionary *)tweet {
    NSDictionary *user;
    if ([self isRetweetTweet:tweet]) {
        user = [tweet valueForKeyPath:TWITTER_RETWEET_USER];
        self.userTweetText.text = [tweet valueForKeyPath:TWITTER_RETWEET_TEXT];
        [self configureCellForRetweet:tweet];
    }
    else {
        user = [tweet valueForKeyPath:TWITTER_TWEET_USER];
        self.userTweetText.text = [tweet valueForKeyPath:TWITTER_TWEET_TEXT];
        self.retweetLabel.text = @"";
        self.retweetIconImageView.image = nil;
    }
    if ([TwitterUser isVerifiedUser:user]) {
        self.twitterVerifiedIcon.hidden = NO;
    }
    else {
        self.twitterVerifiedIcon.hidden = YES;
    }
    [self configureRetweetButtonForRetweetStatus:[[tweet valueForKeyPath:@"retweeted"]boolValue] retweetCount:[NSString stringWithFormat:@"%@",[tweet valueForKeyPath:TWITTER_TWEET_RETWEET_COUNT]]];
    
    //TO-DO Explore programatically creating auto layout contraints
    //[self addToCellProfileImageOfUser:user];
    //[self addToCellFullNameLabel:user];
    //[self addToCellTweetLabel:tweet];
    
    self.userFullName.text = [user valueForKeyPath:TWITTER_USER_FULL_NAME];
    self.profileImageUrl = [NSURL URLWithString:[user valueForKey:TWITTER_USER_PROFILE_IMAGE]];
    [self configureProfileImageFromUrl:self.profileImageUrl];
    self.retweetButton.restorationIdentifier = [NSString stringWithFormat:@"%@",[tweet valueForKeyPath:TWITTER_TWEET_ID] ];
    [self addToCellTime:[tweet valueForKeyPath:TWITTER_TWEET_CREATED_AT]];
}

- (IBAction)retweet:(UIButton *)sender {
    NSString *userID = [Twitter sharedInstance].sessionStore.session.userID;
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    NSDictionary *params = @{@"id" : sender.restorationIdentifier};
    NSError *clientError;
    
    if (self.retweetButton.tag == 0) {
        NSURLRequest *request = [client URLRequestWithMethod:@"POST" URL:[RETWEET_ENDPOINT stringByAppendingString:[sender.restorationIdentifier stringByAppendingString:@".json"]] parameters:params error:&clientError];
        
        if (request) {
            [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (data) {
                    NSLog(@"Retweet Done");
                    [self configureRetweetButtonForRetweetStatus:YES retweetCount:[NSString stringWithFormat:@"%d",[self.retweetCountLabel.text intValue] + 1]];
                }
                else {
                    NSLog(@"Error: %@", connectionError);
                }
            }];
        }
    }
    else if (self.retweetButton.tag == 1) {
        NSURLRequest *request = [client URLRequestWithMethod:@"POST" URL:[UNRETWEET_ENDPOINT stringByAppendingString:[sender.restorationIdentifier stringByAppendingString:@".json"]] parameters:params error:&clientError];
        
        if (request) {
            [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (data) {
                    NSLog(@"Unretweet Done");
                    [self configureRetweetButtonForRetweetStatus:NO retweetCount:[NSString stringWithFormat:@"%d",[self.retweetCountLabel.text intValue] - 1]];
                }
                else {
                    NSLog(@"Error: %@", connectionError);
                }
            }];
        }
    }
}
@end
