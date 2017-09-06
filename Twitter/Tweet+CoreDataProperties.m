//
//  Tweet+CoreDataProperties.m
//  Twitter
//
//  Created by nitesh.vi on 06/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "Tweet+CoreDataProperties.h"

@implementation Tweet (CoreDataProperties)

+ (NSFetchRequest<Tweet *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Tweet"];
}

@dynamic id;
@dynamic text;
@dynamic favorited;
@dynamic retweeted;
@dynamic isRetweet;
@dynamic profileImageUrl;
@dynamic userFullName;
@dynamic retweetedBy;
@dynamic isVerifiedUser;
@dynamic isMediaAttached;
@dynamic mediaUrl;
@dynamic favoriteCount;
@dynamic retweetCount;

@end
