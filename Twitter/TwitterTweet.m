//
//  TwitterTweet.m
//  Twitter
//
//  Created by nitesh.vi on 30/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "TwitterTweet.h"
#import "TwitterFetcher.h"

@implementation TwitterTweet

+ (BOOL)isRetweetTweet:(NSDictionary *)tweet {
    if ([tweet valueForKey:TWITTER_TWEET_RETWEET_STATUS]) {
        return YES;
    }
    return NO;
}

+ (NSDictionary *)getUserFromTweet:(NSDictionary *)tweet {
    return [tweet valueForKeyPath:TWITTER_TWEET_USER];
}

+ (NSDictionary *)getRetweetUserFromTweet:(NSDictionary *)tweet {
    return [tweet valueForKeyPath:TWITTER_TWEET_RETWEET_USER];
}

@end
