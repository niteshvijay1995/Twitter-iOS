//
//  Tweet+TwitterTweet.h
//  Twitter
//
//  Created by nitesh.vi on 06/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "Tweet+CoreDataClass.h"
#import "Tweet+CoreDataProperties.h"

@interface Tweet (TwitterTweet)

+ (Tweet *)tweetWithTweetDictionary:(NSDictionary *)tweetDictionary inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)laodTweetsFromTweetArray:(NSArray *)tweets intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
