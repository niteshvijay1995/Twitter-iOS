//
//  Tweet+CoreDataProperties.m
//  Twitter
//
//  Created by nitesh.vi on 07/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "Tweet+CoreDataProperties.h"

@implementation Tweet (CoreDataProperties)

+ (NSFetchRequest<Tweet *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Tweet"];
}

@dynamic favoriteCount;
@dynamic favorited;
@dynamic id;
@dynamic isMediaAttached;
@dynamic isRetweet;
@dynamic isVerifiedUser;
@dynamic mediaUrl;
@dynamic profileImageUrl;
@dynamic retweetCount;
@dynamic retweeted;
@dynamic retweetedBy;
@dynamic text;
@dynamic userFullName;

@end
