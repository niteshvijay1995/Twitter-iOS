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
@property (weak, nonatomic) IBOutlet UILabel *retweetLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userTweetBottomContraintWithoutImage;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *userFullNameTopRetweetLabelContraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *userProfileImageTopRetweetLabelContraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *userProfileImageTopMarginConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *userFullNameLabelTopMarginContraint;


- (void)configureCellUsingTweet:(NSDictionary *)tweet;

@end
