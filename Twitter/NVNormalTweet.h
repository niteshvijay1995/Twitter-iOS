//
//  NVNormalTweet.h
//  Twitter
//
//  Created by nitesh.vi on 15/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NVTweet.h"

@interface NVNormalTweet : NSObject <NVTweet>

@property (nonatomic) int64_t favoriteCount;
@property (nonatomic) BOOL favorited;
@property (nullable, nonatomic) NSString *id;
@property (nonatomic) BOOL isMediaAttached;
@property (nonatomic) BOOL isRetweet;
@property (nonatomic) BOOL isVerifiedUser;
@property (nullable, nonatomic) NSString *mediaUrl;
@property (nullable, nonatomic) NSString *profileImageUrl;
@property (nonatomic) int64_t retweetCount;
@property (nonatomic) BOOL retweeted;
@property (nullable, nonatomic) NSString *retweetedBy;
@property (nullable, nonatomic) NSObject *text;
@property (nullable, nonatomic) NSString *userFullName;

@end
