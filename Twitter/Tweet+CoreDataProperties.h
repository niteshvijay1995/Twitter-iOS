//
//  Tweet+CoreDataProperties.h
//  Twitter
//
//  Created by nitesh.vi on 07/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "Tweet+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Tweet (CoreDataProperties)

+ (NSFetchRequest<Tweet *> *)fetchRequest;

@property (nonatomic) int64_t favoriteCount;
@property (nonatomic) BOOL favorited;
@property (nullable, nonatomic, copy) NSString *id;
@property (nonatomic) BOOL isMediaAttached;
@property (nonatomic) BOOL isRetweet;
@property (nonatomic) BOOL isVerifiedUser;
@property (nullable, nonatomic, copy) NSString *mediaUrl;
@property (nullable, nonatomic, copy) NSString *profileImageUrl;
@property (nonatomic) int64_t retweetCount;
@property (nonatomic) BOOL retweeted;
@property (nullable, nonatomic, copy) NSString *retweetedBy;
@property (nullable, nonatomic, retain) NSObject *text;
@property (nullable, nonatomic, copy) NSString *userFullName;

@end

NS_ASSUME_NONNULL_END
