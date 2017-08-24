//
//  UserProfileTweetTableViewCell.m
//  Twitter
//
//  Created by nitesh.vi on 25/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "UserProfileTweetTableViewCell.h"
#import "TwitterFetcher.h"
#import "TwitterUser.h"

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
            self.userProfileImage.image = image;
        });
    });
}

- (void)configureCellUsingTweet:(NSDictionary *)tweet {
    NSDictionary *user = [tweet valueForKey:TWITTER_TWEET_USER];
    if ([TwitterUser isVerifiedUser:user]) {
        self.twitterVerifiedIcon.hidden = NO;
    }
    else {
        self.twitterVerifiedIcon.hidden = YES;
    }
    
    self.userFullName.text = [user valueForKey:TWITTER_USER_FULL_NAME];
    self.userTweetText.text = [tweet valueForKey:TWITTER_TWEET_TEXT];
    [self configureProfileImageFromUrl:[NSURL URLWithString: [user valueForKey:TWITTER_USER_PROFILE_IMAGE]]];
}

@end
