//
//  Tweet+TwitterTweetParser.m
//  Twitter
//
//  Created by nitesh.vi on 06/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "Tweet+TwitterTweetParser.h"
#import "TwitterTweet.h"
#import "TwitterFetcher.h"
#import <UIKit/UIKit.h>

@implementation Tweet (TwitterTweetParser)

+ (Tweet *)tweetWithTweetDictionary:(NSDictionary *)tweetDictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Tweet *tweet = nil;
    
    NSString *id = [TwitterTweet getTweetIDForTweet:tweetDictionary];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %@",id];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || [matches count] > 1) {
        // handle error
    } else if ([matches count]){
        tweet = [matches firstObject];
        tweet.favorited = [[tweetDictionary valueForKeyPath:TWITTER_TWEET_FAVORITED_FLAG] boolValue];
        tweet.retweeted = [[tweetDictionary valueForKeyPath:TWITTER_TWEET_RETWEETED_FLAG] boolValue];
        tweet.favoriteCount = [[tweetDictionary valueForKeyPath:TWITTER_TWEET_FAVORITE_COUNT] intValue];
        tweet.retweetCount = [[tweetDictionary valueForKeyPath:TWITTER_TWEET_RETWEET_COUNT] intValue];
        [context save:NULL];
    } else {
        tweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet" inManagedObjectContext:context];
        tweet.id = [NSString stringWithFormat:@"%@",[tweetDictionary valueForKeyPath:TWITTER_TWEET_ID]];
        tweet.text = [self getAttributedStringForTweet:tweetDictionary];
        tweet.favorited = [[tweetDictionary valueForKeyPath:TWITTER_TWEET_FAVORITED_FLAG] boolValue];
        tweet.retweeted = [[tweetDictionary valueForKeyPath:TWITTER_TWEET_RETWEETED_FLAG] boolValue];
        tweet.isRetweet = [tweetDictionary valueForKey:TWITTER_TWEET_RETWEET_STATUS]?YES:NO;
        NSDictionary *user = [tweetDictionary valueForKeyPath:TWITTER_TWEET_USER];
        if (tweet.isRetweet) {
            tweet.retweetedBy = [user valueForKeyPath:TWITTER_USER_FULL_NAME];
            user = [tweetDictionary valueForKeyPath:TWITTER_TWEET_RETWEET_USER];
        }
        tweet.profileImageUrl = [user valueForKey:TWITTER_USER_PROFILE_IMAGE];
        tweet.userFullName = [user valueForKeyPath:TWITTER_USER_FULL_NAME];
        tweet.isVerifiedUser = [[NSString stringWithFormat:@"%@", [user valueForKey:TWITTER_USER_VERIFIED_FLAG]] isEqualToString:@"1"];
        tweet.isMediaAttached = [tweetDictionary valueForKeyPath:TWITTER_TWEET_MEDIA] ? YES : NO ;
        if (tweet.isMediaAttached) {
            NSArray *medias = [tweetDictionary valueForKeyPath:TWITTER_TWEET_MEDIA];
            tweet.mediaUrl = [medias.firstObject valueForKeyPath:TWITTER_TWEET_MEDIA_URL];
        }
        tweet.favoriteCount = [[tweetDictionary valueForKeyPath:TWITTER_TWEET_FAVORITE_COUNT] intValue];
        tweet.retweetCount = [[tweetDictionary valueForKeyPath:TWITTER_TWEET_RETWEET_COUNT] intValue];
    }
    return tweet;
}


// OPTIMIZE-ME
+ (void)laodTweetsFromTweetArray:(NSArray *)tweets intoManagedObjectContext:(NSManagedObjectContext *)context {
    for (NSDictionary *tweet in tweets) {
        [self tweetWithTweetDictionary:tweet inManagedObjectContext:context];
    }
}

+ (NSMutableAttributedString *)getAttributedStringForTweet:(NSDictionary *)tweet {
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


@end
