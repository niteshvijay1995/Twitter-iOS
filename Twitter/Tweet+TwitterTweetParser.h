//
//  Tweet+TwitterTweetParser.h
//  Twitter
//
//  Created by nitesh.vi on 06/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "Tweet+CoreDataProperties.h"
#import "NVTweet.h"

@interface Tweet (TwitterTweetParser) <NVTweet>

+ (Tweet *)tweetWithTweetDictionary:(NSDictionary *)tweetDictionary inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)laodTweetsFromTweetArray:(NSArray *)tweets intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
