//
//  UserProfileTweetTableViewCell.h
//  Twitter
//
//  Created by nitesh.vi on 25/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileTweetTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userFullName;
@property (weak, nonatomic) IBOutlet UILabel *userTweetText;
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (weak, nonatomic) IBOutlet UIImageView *twitterVerifiedIcon;

- (void)configureCellUsingTweet:(NSDictionary *)tweet;

@end
