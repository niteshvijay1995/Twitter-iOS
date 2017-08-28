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
    self.userProfileImage.image = [UIImage imageNamed:@"default_profile_normal"];
    dispatch_queue_t imageFetchQ = dispatch_queue_create("profile image fetcher", NULL);
    dispatch_async(imageFetchQ, ^{
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: profileImageUrl];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([profileImageUrl isEqual:self.profileImageUrl]) {
                self.userProfileImage.image = image;
            }
        });
    });
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

/* For Exploration - programatically creating auto layout contraints
- (void)addToCellTweetLabel:(NSDictionary *)tweet {
    self.tweetTextLabel = [[UILabel alloc] init];
    [self.tweetTextLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.tweetTextLabel.text = [tweet valueForKeyPath:TWITTER_TWEET_TEXT];
    [self.tweetTextLabel setFont:[UIFont fontWithName:@"System" size:13]];
    [self.tweetTextLabel sizeToFit];
    self.tweetTextLabel.numberOfLines = 0;
    [self.contentView addSubview:self.tweetTextLabel];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tweetTextLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.userFullNameLabel attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tweetTextLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.userFullNameLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:4.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tweetTextLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottomMargin multiplier:1.0 constant:4.0]];
}

- (void)addToCellFullNameLabel:(NSDictionary *)user {
    self.userFullNameLabel = [[UILabel alloc] init];
    [self.userFullNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.userFullNameLabel.text = [user valueForKeyPath:TWITTER_USER_FULL_NAME];
    [self.userFullNameLabel setFont:[UIFont fontWithName:@"System Bold" size:14]];
    [self.userFullNameLabel sizeToFit];
    [self.contentView addSubview:self.userFullNameLabel];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.userFullNameLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.userProfileImageView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:5.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.userFullNameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTopMargin multiplier:1.0 constant:5.0]];
    
}

- (void)addToCellProfileImageOfUser:(NSDictionary *)user {
    //TO-DO Set Image size according to screen size
    self.userProfileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self.userProfileImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.userProfileImageView.image = [UIImage imageNamed:@"default_profile_normal"];
    self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.size.height/2;
    self.userProfileImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.userProfileImageView];
    
    [self.userProfileImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.userProfileImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:50]];
    [self.userProfileImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.userProfileImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:50]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.userProfileImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTopMargin multiplier:1.0 constant:2.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.userProfileImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeftMargin multiplier:1.0 constant:2.0]];
    
}
*/

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
    if ([[tweet valueForKeyPath:@"retweeted"]boolValue]) {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweeted_icon"] forState:UIControlStateNormal];
        self.retweetButton.tag = 1;
    }
    else {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_icon"] forState:UIControlStateNormal];
        self.retweetButton.tag = 0;
    }
    [self setNeedsLayout];
    //TO-DO Explore programatically creating auto layout contraints
    
    //[self addToCellProfileImageOfUser:user];
    //[self addToCellFullNameLabel:user];
    //[self addToCellTweetLabel:tweet];
    
    self.userFullName.text = [user valueForKeyPath:TWITTER_USER_FULL_NAME];
    self.profileImageUrl = [NSURL URLWithString:[user valueForKey:TWITTER_USER_PROFILE_IMAGE]];
    [self configureProfileImageFromUrl:self.profileImageUrl];
    self.retweetButton.restorationIdentifier = [NSString stringWithFormat:@"%@",[tweet valueForKeyPath:TWITTER_TWEET_ID] ];
    [self addToCellTime:[tweet valueForKeyPath:TWITTER_TWEET_CREATED_AT]];
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%@",[tweet valueForKeyPath:TWITTER_TWEET_RETWEET_COUNT]];
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
                    [self.retweetButton setImage:[UIImage imageNamed:@"retweeted_icon"] forState:UIControlStateNormal];
                    self.retweetButton.tag = 1;
                    self.retweetCountLabel.text = [NSString stringWithFormat:@"%d",[self.retweetCountLabel.text intValue] + 1];
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
                    [self.retweetButton setImage:[UIImage imageNamed:@"retweet_icon"] forState:UIControlStateNormal];
                    self.retweetButton.tag = 0;
                    self.retweetCountLabel.text = [NSString stringWithFormat:@"%d",[self.retweetCountLabel.text intValue] - 1];
                }
                else {
                    NSLog(@"Error: %@", connectionError);
                }
            }];
        }
    }
}
@end
