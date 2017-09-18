//
//  CustomUserDetailCell.h
//  
//
//  Created by nitesh.vi on 23/08/17.
//
//

#import <UIKit/UIKit.h>

@interface CustomUserDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userFullName;
@property (weak, nonatomic) IBOutlet UILabel *userHandle;
@property (weak, nonatomic) IBOutlet UILabel *userDescription;
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (weak, nonatomic) IBOutlet UIImageView *twitterVerifiedIcon;

- (void)configureCellUsingUser:(NSDictionary *)user;

@end
