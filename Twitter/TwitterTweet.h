//
//  TwitterTweet.h
//  Twitter
//
//  Created by nitesh.vi on 30/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterTweet : NSObject
+ (BOOL)isRetweetTweet:(NSDictionary *)tweet;
+ (NSDictionary *)getUserFromTweet:(NSDictionary *)tweet;
+ (NSDictionary *)getRetweetUserFromTweet:(NSDictionary *)tweet;
+ (BOOL)isMediaAssociatedWithTweet:(NSDictionary *)tweet;
+ (NSURL *)getMediaImageUrlFromTweet:(NSDictionary *)tweet;
+ (NSString *)getFavoritesCountForTweet:(NSDictionary *)tweet;
+ (NSString *)getRetweetsCountForTweet:(NSDictionary *)tweet;
+ (NSString *)getTweetIDForTweet:(NSDictionary *)tweet;
+ (BOOL)isFavoritedTweet:(NSDictionary *)tweet;
+ (BOOL)isRetweetedTweet:(NSDictionary *)tweet;
+ (void)likeTweetWithId:tweetId;
+ (void)unlikeTweetWithId:tweetId;
+ (void)retweetTweetWithId:tweetId;
+ (void)unretweetTweetWithId:tweetId;
+ (NSString *)getCreatedAtForTweet:(NSDictionary *)tweet;
@end
