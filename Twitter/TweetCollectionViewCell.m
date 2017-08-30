//
//  TweetCollectionViewCell.m
//  Twitter
//
//  Created by nitesh.vi on 28/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "TweetCollectionViewCell.h"
#import "PureLayout.h"
#import "TwitterFetcher.h"
#import "TwitterUser.h"
#import "ProfileImageCache.h"

@interface TweetCollectionViewCell()
@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *fullNameLabel;
@property (strong, nonatomic) UILabel *tweetLabel;
@property (strong, nonatomic) NSOperationQueue *imageDownloaderQueue;
@property (strong, nonatomic) NSURL *profileImageUrl;
@property (strong, nonatomic) UIImageView *verifiedUserIcon;
@end

@implementation TweetCollectionViewCell

static int LEFT_RIGHT_CELL_INSET = 4;
static float PROFILE_IMAGE_SCALE_FACTOR = 0.12;
static float VERIFIED_ICON_SCALE_FACTOR = 0.03;
static int OPERATION_QUEUE_MAX_CONCURRENT_OPERATION_COUNT = 3;
static float CELL_BORDER_WIDTH = 1.0;

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.tweetCellViewWidthConstraint.constant = [self screenWidth] - (2*LEFT_RIGHT_CELL_INSET);
    
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.borderWidth = CELL_BORDER_WIDTH;
    
    self.layer.cornerRadius = 5;
    
    self.imageDownloaderQueue = [[NSOperationQueue alloc] init];
    self.imageDownloaderQueue.maxConcurrentOperationCount = OPERATION_QUEUE_MAX_CONCURRENT_OPERATION_COUNT;
    
    [self addProfileImageView];
    [self addFullNameLabel];
    [self addTweetLabel];
    [self addVerifiedUserIcon];
    
}

- (void)configureCellFromTweet:(NSDictionary *)tweet
{
    NSDictionary *user = [tweet valueForKeyPath:TWITTER_TWEET_USER];
    self.profileImageUrl = [NSURL URLWithString:[user valueForKey:TWITTER_USER_PROFILE_IMAGE]];
    [self addProfileImageFromUrl:self.profileImageUrl];
    [self addFullNameLabelWithFullName:[user valueForKeyPath:TWITTER_USER_FULL_NAME]];
    [self addTweetLabelWithTweet:tweet];
    if ([TwitterUser isVerifiedUser:user]) {
        self.verifiedUserIcon.hidden = NO;
    }
    else {
        self.verifiedUserIcon.hidden = YES;
    }
}

- (CGFloat)screenWidth {
    return  [UIScreen mainScreen].bounds.size.width;
}

- (void)addProfileImageFromUrl:(NSURL *)profileImageUrl {
    UIImage *profileImage = [[ProfileImageCache sharedInstance] getCachedImageForKey:profileImageUrl.absoluteString];
    if (profileImage) {
        self.profileImageView.image = profileImage;
    }
    else {
        self.profileImageView.image = [UIImage imageNamed:@"default_profile_normal"];
        [self.imageDownloaderQueue addOperationWithBlock:^{
            NSData * imageData = [[NSData alloc] initWithContentsOfURL: profileImageUrl];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[ProfileImageCache sharedInstance] cacheImage:image forKey:profileImageUrl.absoluteString];
                if ([profileImageUrl isEqual:self.profileImageUrl]) {
                    self.profileImageView.image = image;
                }
            }];
        }];
    }
}

- (void)addFullNameLabelWithFullName:(NSString *)fullName {
    self.fullNameLabel.text = fullName;
}

- (void)addTweetLabelWithTweet:(NSDictionary *)tweet {
    self.tweetLabel.attributedText = [self getAttributedStringForTweet:tweet];
}

- (void)addProfileImageView {
    self.profileImageView = [[UIImageView alloc] init];
    
    self.profileImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tweetCellView addSubview:self.profileImageView];
    
    CGFloat size = PROFILE_IMAGE_SCALE_FACTOR*[self screenWidth];
    
    [self.profileImageView autoSetDimensionsToSize:CGSizeMake(size,size)];
    [self.profileImageView autoConstrainAttribute:ALAttributeTop toAttribute:ALAttributeMarginTop ofView:self.tweetCellView withOffset:2 relation:NSLayoutRelationEqual];
    [self.profileImageView layoutIfNeeded];
    [self.profileImageView autoConstrainAttribute:ALAttributeLeading toAttribute:ALAttributeMarginLeading ofView:self.tweetCellView withOffset:2 relation:NSLayoutRelationEqual];
    [self.profileImageView autoConstrainAttribute:ALAttributeBottom toAttribute:ALAttributeMarginBottom ofView:self.tweetCellView withOffset:-10 relation:NSLayoutRelationLessThanOrEqual];
    
    [self.profileImageView layoutIfNeeded];
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2;
    self.profileImageView.image = [UIImage imageNamed:@"default_profile_normal"];
    self.profileImageView.clipsToBounds = YES;
    
}

- (void)addFullNameLabel {
    self.fullNameLabel = [[UILabel alloc] init];
    
    self.fullNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tweetCellView addSubview:self.fullNameLabel];
    
    [self.fullNameLabel autoConstrainAttribute:ALAttributeLeading toAttribute:ALAttributeTrailing ofView:self.profileImageView withOffset:8 relation:NSLayoutRelationEqual];
    [self.fullNameLabel autoConstrainAttribute:ALAttributeTop toAttribute:ALAttributeTop ofView:self.profileImageView withOffset:0 relation:NSLayoutRelationEqual];
    
    self.fullNameLabel.numberOfLines = 1;
    self.fullNameLabel.text = @"Full Name";
    [self.fullNameLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [self.fullNameLabel sizeToFit];
}

- (void)addTweetLabel {
    self.tweetLabel = [[UILabel alloc] init];
    
    self.tweetLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tweetCellView addSubview:self.tweetLabel];
    
    [self.tweetLabel autoConstrainAttribute:ALAttributeLeading toAttribute:ALAttributeLeading ofView:self.fullNameLabel withOffset:0 relation:NSLayoutRelationEqual];
    [self.tweetLabel autoConstrainAttribute:ALAttributeTop toAttribute:ALAttributeBottom ofView:self.fullNameLabel withOffset:2 relation:NSLayoutRelationEqual];
    [self.tweetLabel autoConstrainAttribute:ALAttributeBottom toAttribute:ALAttributeMarginBottom ofView:self.tweetCellView withOffset:-4 relation:NSLayoutRelationEqual];
    [self.tweetLabel autoConstrainAttribute:ALAttributeTrailing toAttribute:ALAttributeMarginTrailing ofView:self.tweetCellView withOffset:4];
    
    self.tweetLabel.numberOfLines = 0;
    self.tweetLabel.text = @"Tweet";
    [self.tweetLabel setFont:[UIFont systemFontOfSize:15]];
    [self.tweetLabel sizeToFit];
}

- (void)addVerifiedUserIcon {
    self.verifiedUserIcon = [[UIImageView alloc] init];
    
    self.verifiedUserIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tweetCellView addSubview:self.verifiedUserIcon];
    
    CGFloat size = VERIFIED_ICON_SCALE_FACTOR*[self screenWidth];
    [self.verifiedUserIcon autoSetDimensionsToSize:CGSizeMake(size,size)];
    
    [self.verifiedUserIcon autoConstrainAttribute:ALAttributeLeading toAttribute:ALAttributeTrailing ofView:self.fullNameLabel withOffset:5];
    [self.verifiedUserIcon autoConstrainAttribute:ALAttributeHorizontal toAttribute:ALAttributeHorizontal ofView:self.fullNameLabel withOffset:0];
    [self.verifiedUserIcon layoutIfNeeded];
    self.verifiedUserIcon.image = [UIImage imageNamed:@"twitter_verified_icon"];
    self.verifiedUserIcon.clipsToBounds = YES;
}

@end
