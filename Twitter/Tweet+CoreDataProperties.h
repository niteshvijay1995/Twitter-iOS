//
//  Tweet+CoreDataProperties.h
//  Twitter
//
//  Created by nitesh.vi on 06/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "Tweet+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Tweet (CoreDataProperties)

+ (NSFetchRequest<Tweet *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *id;
@property (nullable, nonatomic, retain) NSAttributedString *text;
@property (nonatomic) BOOL favorited;
@property (nonatomic) BOOL retweeted;
@property (nonatomic) BOOL isRetweet;
@property (nullable, nonatomic, copy) NSString *profileImageUrl;
@property (nullable, nonatomic, copy) NSString *userFullName;
@property (nullable, nonatomic, copy) NSString *retweetedBy;
@property (nonatomic) BOOL isVerifiedUser;
@property (nonatomic) BOOL isMediaAttached;
@property (nullable, nonatomic, copy) NSString *mediaUrl;
@property (nonatomic) int64_t favoriteCount;
@property (nonatomic) int64_t retweetCount;

@end

NS_ASSUME_NONNULL_END
