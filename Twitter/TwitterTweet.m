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

+ (BOOL)isMediaAssociatedWithTweet:(NSDictionary *)tweet {
    if ([tweet valueForKeyPath:TWITTER_TWEET_MEDIA]) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (NSURL *)getMediaImageUrlFromTweet:(NSDictionary *)tweet {
    NSArray *medias = [tweet valueForKeyPath:TWITTER_TWEET_MEDIA];
    return [NSURL URLWithString:[medias.firstObject valueForKeyPath:TWITTER_TWEET_MEDIA_URL]];
}
@end
