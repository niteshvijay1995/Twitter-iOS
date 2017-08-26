//
//  CustomUserDetailCell.m
//  
//
//  Created by nitesh.vi on 23/08/17.
//
//

#import "CustomUserDetailCell.h"
#import "TwitterFetcher.h"

@interface CustomUserDetailCell()
@property (strong, nonatomic) NSURL *profileImageUrl;

@end

@implementation CustomUserDetailCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)isVerifiedUser:(NSDictionary *)user {
    return [[NSString stringWithFormat:@"%@", [user valueForKey:TWITTER_USER_VERIFIED_FLAG]] isEqualToString:@"1"];
}

- (NSString *)getUserHandleOfUser:(NSDictionary *)user {
    return [@"@" stringByAppendingString:[user valueForKey:TWITTER_USER_SCREEN_NAME]];
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

- (void)configureCellUsingUser:(NSDictionary *)user {
    if ([self isVerifiedUser:user]) {
        self.twitterVerifiedIcon.hidden = NO;
    }
    else {
        self.twitterVerifiedIcon.hidden = YES;
    }
    self.userFullName.text = [user valueForKey:TWITTER_USER_FULL_NAME];
    self.userHandle.text = [self getUserHandleOfUser:user];
    self.userDescription.text = [user valueForKey:TWITTER_USER_DESCRIPTION];
    self.profileImageUrl = [NSURL URLWithString: [user valueForKey:TWITTER_USER_PROFILE_IMAGE]];
    [self configureProfileImageFromUrl:self.profileImageUrl];
}


@end
