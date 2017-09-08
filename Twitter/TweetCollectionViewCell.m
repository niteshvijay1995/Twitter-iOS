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
#import "ImageCache.h"
#import "TwitterTweet.h"
#import "TwitterUser.h"
#import "TweetOptionsFooterBarView.h"
#import "Tweet+CoreDataProperties.h"

@interface TweetCollectionViewCell()
@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *fullNameLabel;
@property (strong, nonatomic) UILabel *tweetLabel;
@property (strong, nonatomic) NSOperationQueue *imageDownloaderQueue;
@property (strong, nonatomic) NSURL *profileImageUrl;
@property (strong, nonatomic) UIImageView *verifiedUserIcon;
@property (strong, nonatomic) UILabel *retweetLabel;
@property (strong, nonatomic) UIImageView *mediaImageView;
@property (strong, nonatomic) NSURL *mediaImageUrl;
@property (strong, nonatomic) TweetOptionsFooterBarView *footerView;
@property (strong, nonatomic) NSLayoutConstraint *profileImage_TopMarginConstraint;
@property (strong, nonatomic) NSLayoutConstraint *profileImage_RetweetLabelContraint;
@property (strong, nonatomic) NSLayoutConstraint *mediaImageHeightConstraint;
@end

@implementation TweetCollectionViewCell

static int LEFT_RIGHT_CELL_INSET = 4;
static float PROFILE_IMAGE_SCALE_FACTOR = 0.13;
static float VERIFIED_ICON_SCALE_FACTOR = 0.03;
static int OPERATION_QUEUE_MAX_CONCURRENT_OPERATION_COUNT = 3;
static float CELL_BORDER_WIDTH = 1.0;
static float MEDIA_IMAGE_ASPECT_RATIO = 0.55;           // Aspect ratio = Height/Width

- (NSLayoutConstraint *)profileImage_TopMarginConstraint {
    if (!_profileImage_TopMarginConstraint) {
        [NSLayoutConstraint autoSetPriority:UILayoutPriorityDefaultLow forConstraints:^{
            _profileImage_TopMarginConstraint = [NSLayoutConstraint autoCreateAndInstallConstraints:^{
                [self.profileImageView autoConstrainAttribute:ALAttributeTop toAttribute:ALAttributeMarginTop ofView:self.tweetCellView withOffset:2 relation:NSLayoutRelationEqual];
            }].firstObject;
        }];
        
    }
    return _profileImage_TopMarginConstraint;
}
    
- (NSLayoutConstraint *)profileImage_RetweetLabelContraint {
    if (!_profileImage_RetweetLabelContraint) {
        [NSLayoutConstraint autoSetPriority:UILayoutPriorityDefaultLow forConstraints:^{ _profileImage_RetweetLabelContraint = [NSLayoutConstraint autoCreateAndInstallConstraints:^{
            [self.profileImageView autoConstrainAttribute:ALAttributeTop toAttribute:ALAttributeBottom ofView:self.retweetLabel withOffset:2 relation:NSLayoutRelationEqual];
        }].firstObject;
        }];
    }
    return _profileImage_RetweetLabelContraint;
}

- (NSLayoutConstraint *)mediaImageHeightConstraint {
    if (!_mediaImageHeightConstraint) {
        _mediaImageHeightConstraint = [self.mediaImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:self.mediaImageView withMultiplier:MEDIA_IMAGE_ASPECT_RATIO relation:NSLayoutRelationEqual];
    }
    return _mediaImageHeightConstraint;
}

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
    [self addRetweetLabel];
    [self addMediaImageView];
    [self addFooterView];
    
}


- (void)configureCellFromTweet:(NSDictionary *)tweet
{
    NSDictionary *user;
    if ([TwitterTweet isRetweetTweet:tweet]) {
        
        [self addTweetLabelWithTweet:[tweet valueForKeyPath:TWITTER_RETWEET]];
        user = [TwitterTweet getRetweetUserFromTweet:tweet];
        [self addRetweetLabelTextUsingUser:[TwitterTweet getUserFromTweet:tweet]];
    }
    else {
        [self addTweetLabelWithTweet:tweet];
        user = [TwitterTweet getUserFromTweet:tweet];
    }

    self.profileImageUrl = [TwitterUser getProfileImageUrlForUser:user];
    [self addProfileImageFromUrl:self.profileImageUrl];
    [self addFullNameLabelWithFullName:[user valueForKeyPath:TWITTER_USER_FULL_NAME]];
    
    [self configureRetweetLabelConstraintsForTweet:tweet];
    
    if ([TwitterUser isVerifiedUser:user]) {
        self.verifiedUserIcon.hidden = NO;
    }
    else {
        self.verifiedUserIcon.hidden = YES;
    }
    self.mediaImageView.image = nil;
    [self.mediaImageView removeConstraint:self.mediaImageHeightConstraint];
    self.mediaImageUrl = [TwitterTweet getMediaImageUrlFromTweet:tweet];
    if ([TwitterTweet isMediaAssociatedWithTweet:tweet]) {
        [self addMediaImageFromTweet:self.mediaImageUrl];
    }
    [self addDataToFooterForTweet:tweet];
    
}

- (void)configureCellFromCoreDataTweet:(Tweet *)tweet {
    self.tweetLabel.attributedText = tweet.text;
    if (tweet.isRetweet) {
        self.retweetLabel.text = [tweet.retweetedBy stringByAppendingString:@" retweeted"];
    }
    self.profileImageUrl = [NSURL URLWithString:tweet.profileImageUrl];
    [self addProfileImageFromUrl:self.profileImageUrl];
    
    self.fullNameLabel.text = tweet.userFullName;
    
    if (tweet.isRetweet)  {
        self.retweetLabel.hidden = NO;
        self.profileImage_RetweetLabelContraint.priority = UILayoutPriorityDefaultHigh;
        self.profileImage_TopMarginConstraint.priority = UILayoutPriorityDefaultLow;
    }
    else {
        self.retweetLabel.hidden = YES;
        self.profileImage_RetweetLabelContraint.priority = UILayoutPriorityDefaultLow;
        self.profileImage_TopMarginConstraint.priority = UILayoutPriorityDefaultHigh;
    }
    
    if (tweet.isVerifiedUser) {
        self.verifiedUserIcon.hidden = NO;
    }
    else {
        self.verifiedUserIcon.hidden = YES;
    }
    
    self.mediaImageView.image = nil;
    [self.mediaImageView removeConstraint:self.mediaImageHeightConstraint];
    self.mediaImageUrl = [NSURL URLWithString:tweet.mediaUrl];
    if (tweet.isMediaAttached) {
        [self addMediaImageFromTweet:self.mediaImageUrl];
    }
    
    self.footerView.likeCountLabel.text = [NSString stringWithFormat:@"%lld",tweet.favoriteCount];
    self.footerView.retweetCountLabel.text = [NSString stringWithFormat:@"%lld",tweet.retweetCount];
    
    self.footerView.likeButton.restorationIdentifier = tweet.id;
    self.footerView.retweetButton.restorationIdentifier = tweet.id;
    
    if(tweet.favorited){
        self.footerView.likeButton.tag = 1;
        self.footerView.likeIconImageView.image = [UIImage imageNamed:@"liked_icon"];
        self.footerView.likeCountLabel.textColor = [UIColor redColor];
    }
    else {
        self.footerView.likeButton.tag = 0;
        self.footerView.likeIconImageView.image = [UIImage imageNamed:@"like_icon"];
        self.footerView.likeCountLabel.textColor = [UIColor blackColor];
    }
    if(tweet.retweeted){
        self.footerView.retweetButton.tag = 1;
        self.footerView.retweetIconImageView.image = [UIImage imageNamed:@"retweeted_icon"];
        self.footerView.retweetCountLabel.textColor = [UIColor greenColor];
        self.footerView.retweetIconImageView.transform = CGAffineTransformMakeRotation((180.0 * M_PI) / 180.0);
    }
    else {
        self.footerView.retweetButton.tag = 0;
        self.footerView.retweetIconImageView.image = [UIImage imageNamed:@"retweet_icon"];
        self.footerView.retweetCountLabel.textColor = [UIColor blackColor];
    }
}

- (void)configureRetweetLabelConstraintsForTweet:(NSDictionary *)tweet {
    if ([TwitterTweet isRetweetTweet:tweet])  {
        self.retweetLabel.hidden = NO;
        self.profileImage_RetweetLabelContraint.priority = UILayoutPriorityDefaultHigh;
        self.profileImage_TopMarginConstraint.priority = UILayoutPriorityDefaultLow;
    }
    else {
        self.retweetLabel.hidden = YES;
        self.profileImage_RetweetLabelContraint.priority = UILayoutPriorityDefaultLow;
        self.profileImage_TopMarginConstraint.priority = UILayoutPriorityDefaultHigh;
    }
}

- (NSMutableAttributedString *)getAttributedStringForTweet:(NSDictionary *)tweet {
    NSMutableAttributedString *tweetString;
    tweetString = [[NSMutableAttributedString alloc]initWithString:[tweet valueForKeyPath:TWITTER_TWEET_TEXT]];
    
    NSArray *userMentions = [tweet valueForKeyPath:TWITTER_TWEET_USER_MENTIONS];
    for(id userMention in userMentions) {
        NSArray *indices = [userMention valueForKeyPath:@"indices"];
        NSRange range = NSMakeRange([indices[0] integerValue] , [indices[1] integerValue]-[indices[0] integerValue]);
        [tweetString addAttributes:@{NSForegroundColorAttributeName : twitterBlueColor} range:range];
    }
    
    NSArray *urls = [tweet valueForKeyPath:TWITTER_TWEET_MEDIA];
    for (id url in urls) {
        NSArray *indices = [url valueForKeyPath:@"indices"];
        NSRange range = NSMakeRange([indices[0] integerValue] , [indices[1] integerValue]-[indices[0] integerValue]);
        [tweetString replaceCharactersInRange:range withString:@""];
        return tweetString;
    }
    return tweetString;
}

- (CGFloat)screenWidth {
    return  [UIScreen mainScreen].bounds.size.width;
}

- (void)addMediaImageFromTweet:(NSURL *)mediaImageUrl {
    [self.mediaImageView addConstraint:self.mediaImageHeightConstraint];
    UIImage *mediaImage = [[ImageCache sharedInstance] getCachedImageForKey:mediaImageUrl.absoluteString];
    if (mediaImage) {
        self.mediaImageView.image = mediaImage;
    }
    else {
        [self.imageDownloaderQueue addOperationWithBlock:^{
            NSData * imageData = [[NSData alloc] initWithContentsOfURL:mediaImageUrl];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            [[ImageCache sharedInstance] cacheImage:image forKey:mediaImageUrl.absoluteString];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if ([self.mediaImageUrl.absoluteString isEqualToString:mediaImageUrl.absoluteString]) {
                    self.mediaImageView.image = image;
                }
            }];
        }];
    }
}

- (void)addRetweetLabelTextUsingUser:(NSDictionary *)user {
    self.retweetLabel.text = [[TwitterUser getFullNameForUser:user] stringByAppendingString:@" retweeted"];
}

- (void)addProfileImageFromUrl:(NSURL *)profileImageUrl {
    UIImage *profileImage = [[ImageCache sharedInstance] getCachedImageForKey:profileImageUrl.absoluteString];
    if (profileImage) {
        self.profileImageView.image = profileImage;
    }
    else {
        self.profileImageView.image = [UIImage imageNamed:@"default_profile_normal"];
        [self.imageDownloaderQueue addOperationWithBlock:^{
            NSData * imageData = [[NSData alloc] initWithContentsOfURL: profileImageUrl];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[ImageCache sharedInstance] cacheImage:image forKey:profileImageUrl.absoluteString];
                if ([profileImageUrl isEqual:self.profileImageUrl]) {
                    self.profileImageView.image = image;
                }
            }];
        }];
    }
}

- (void)addDataToFooterForTweet:(NSDictionary *)tweet {
    self.footerView.likeCountLabel.text = [TwitterTweet getFavoritesCountForTweet:tweet];
    self.footerView.retweetCountLabel.text = [TwitterTweet getRetweetsCountForTweet:tweet];
    
    self.footerView.likeButton.restorationIdentifier = [TwitterTweet getTweetIDForTweet:tweet];
    self.footerView.retweetButton.restorationIdentifier = [TwitterTweet getTweetIDForTweet:tweet];
    
    if([TwitterTweet isFavoritedTweet:tweet]){
        self.footerView.likeButton.tag = 1;
        self.footerView.likeIconImageView.image = [UIImage imageNamed:@"liked_icon"];
        self.footerView.likeCountLabel.textColor = [UIColor redColor];
    }
    else {
        self.footerView.likeButton.tag = 0;
        self.footerView.likeIconImageView.image = [UIImage imageNamed:@"like_icon"];
        self.footerView.likeCountLabel.textColor = [UIColor blackColor];
    }
    if([TwitterTweet isRetweetedTweet:tweet]){
        self.footerView.retweetButton.tag = 1;
        self.footerView.retweetIconImageView.image = [UIImage imageNamed:@"retweeted_icon"];
        self.footerView.retweetCountLabel.textColor = [UIColor greenColor];
        self.footerView.retweetIconImageView.transform = CGAffineTransformMakeRotation((180.0 * M_PI) / 180.0);
    }
    else {
        self.footerView.retweetButton.tag = 0;
        self.footerView.retweetIconImageView.image = [UIImage imageNamed:@"retweet_icon"];
        self.footerView.retweetCountLabel.textColor = [UIColor blackColor];
    }
}

- (void)addFullNameLabelWithFullName:(NSString *)fullName {
    self.fullNameLabel.text = fullName;
}

- (void)addTweetLabelWithTweet:(NSDictionary *)tweet {
    self.tweetLabel.attributedText = [self getAttributedStringForTweet:tweet];
}

- (void)addRetweetLabel {
    self.retweetLabel = [[UILabel alloc] init];
    
    self.retweetLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tweetCellView addSubview:self.retweetLabel];
    
    [self.retweetLabel autoConstrainAttribute:ALAttributeLeading toAttribute:ALAttributeLeading ofView:self.fullNameLabel withOffset:0 relation:NSLayoutRelationEqual];
    [self.retweetLabel autoConstrainAttribute:ALAttributeTop toAttribute:ALAttributeMarginTop ofView:self.tweetCellView withOffset:2 relation:NSLayoutRelationEqual];
    
    self.retweetLabel.numberOfLines = 1;
    self.retweetLabel.text = @"Retweet Label";
    [self.retweetLabel setFont:[UIFont fontWithName:@".SFUIText-Light" size:12]];
    [self.retweetLabel sizeToFit];
    self.retweetLabel.hidden = YES;
}

- (void)addProfileImageView {
    self.profileImageView = [[UIImageView alloc] init];
    
    self.profileImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tweetCellView addSubview:self.profileImageView];
    
    CGFloat size = MIN(PROFILE_IMAGE_SCALE_FACTOR*[self screenWidth], 50) ;
    
    [self.profileImageView autoSetDimensionsToSize:CGSizeMake(size,size)];
    
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

- (void)addVerifiedUserIcon {
    self.verifiedUserIcon = [[UIImageView alloc] init];
    
    self.verifiedUserIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tweetCellView addSubview:self.verifiedUserIcon];
    
    CGFloat size = MIN(VERIFIED_ICON_SCALE_FACTOR*[self screenWidth], 12);
    [self.verifiedUserIcon autoSetDimensionsToSize:CGSizeMake(size,size)];
    
    [self.verifiedUserIcon autoConstrainAttribute:ALAttributeLeading toAttribute:ALAttributeTrailing ofView:self.fullNameLabel withOffset:5];
    [self.verifiedUserIcon autoConstrainAttribute:ALAttributeHorizontal toAttribute:ALAttributeHorizontal ofView:self.fullNameLabel withOffset:0];
    [self.verifiedUserIcon layoutIfNeeded];
    self.verifiedUserIcon.image = [UIImage imageNamed:@"twitter_verified_icon"];
    self.verifiedUserIcon.clipsToBounds = YES;
}

- (void)addTweetLabel {
    self.tweetLabel = [[UILabel alloc] init];
    
    self.tweetLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tweetCellView addSubview:self.tweetLabel];
    
    [self.tweetLabel autoConstrainAttribute:ALAttributeLeading toAttribute:ALAttributeLeading ofView:self.fullNameLabel withOffset:0 relation:NSLayoutRelationEqual];
    [self.tweetLabel autoConstrainAttribute:ALAttributeTop toAttribute:ALAttributeBottom ofView:self.fullNameLabel withOffset:2 relation:NSLayoutRelationEqual];
    //[self.tweetLabel autoConstrainAttribute:ALAttributeBottom toAttribute:ALAttributeMarginBottom ofView:self.tweetCellView withOffset:-4 relation:NSLayoutRelationEqual];
    [self.tweetLabel autoConstrainAttribute:ALAttributeTrailing toAttribute:ALAttributeMarginTrailing ofView:self.tweetCellView withOffset:4];
    
    self.tweetLabel.numberOfLines = 0;
    self.tweetLabel.text = @"Tweet";
    [self.tweetLabel setFont:[UIFont systemFontOfSize:15]];
    [self.tweetLabel sizeToFit];
}

- (void)addMediaImageView {
    self.mediaImageView = [[UIImageView alloc] init];
    
    self.mediaImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tweetCellView addSubview:self.mediaImageView];
    
    
    [self.mediaImageView layoutIfNeeded];
    [self.mediaImageView autoConstrainAttribute:ALAttributeLeading toAttribute:ALAttributeLeading ofView:self.tweetLabel withOffset:0 relation:NSLayoutRelationEqual];
    [self.mediaImageView autoConstrainAttribute:ALAttributeTop toAttribute:ALAttributeBottom ofView:self.tweetLabel withOffset:4 relation:NSLayoutRelationEqual];
    //[self.mediaImageView autoConstrainAttribute:ALAttributeBottom toAttribute:ALAttributeMarginBottom ofView:self.tweetCellView withOffset:-2 relation:NSLayoutRelationEqual];
    [self.mediaImageView autoConstrainAttribute:ALAttributeTrailing toAttribute:ALAttributeMarginTrailing ofView:self.tweetCellView withOffset:-5];
    //[self.mediaImageView addConstraint:self.mediaImageHeightConstraint];
    self.mediaImageView.layer.cornerRadius = 5;
    self.mediaImageView.clipsToBounds = YES;
}

- (void)addFooterView {
    self.footerView = [[NSBundle mainBundle] loadNibNamed:@"TweetOptionsFooterBar" owner:self options:nil].firstObject;
    self.footerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tweetCellView addSubview:self.footerView];
    
    [self.footerView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.tweetLabel];
    [self.footerView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.tweetLabel];
    [self.footerView autoSetDimension:ALDimensionHeight toSize:20];
    [self.footerView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.tweetCellView withOffset:-8];
    [self.footerView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.mediaImageView withOffset:4];
}

@end
