//
//  TwitterTweet.m
//  Twitter
//
//  Created by nitesh.vi on 30/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "TwitterTweet.h"
#import "TwitterFetcher.h"
#import <TwitterKit/TwitterKit.h>

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

+ (NSString *)getFavoritesCountForTweet:(NSDictionary *)tweet {
    return [NSString stringWithFormat:@"%@",[tweet valueForKeyPath:TWITTER_TWEET_FAVORITE_COUNT]];
}

+ (NSString *)getRetweetsCountForTweet:(NSDictionary *)tweet {
    return [NSString stringWithFormat:@"%@",[tweet valueForKeyPath:TWITTER_TWEET_RETWEET_COUNT]];
}

+ (NSString *)getTweetIDForTweet:(NSDictionary *)tweet {
    return [NSString stringWithFormat:@"%@",[tweet valueForKeyPath:TWITTER_TWEET_ID]];
}

+ (BOOL)isFavoritedTweet:(NSDictionary *)tweet {
    return [[tweet valueForKeyPath:TWITTER_TWEET_FAVORITED_FLAG] boolValue];
}

+ (BOOL)isRetweetedTweet:(NSDictionary *)tweet {
    return [[tweet valueForKeyPath:TWITTER_TWEET_RETWEETED_FLAG] boolValue];
}

+ (void)likeTweetWithId:(NSString *)tweetId {
    NSString *userID = [Twitter sharedInstance].sessionStore.session.userID;
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    NSDictionary *params = @{@"id" : tweetId};
    NSError *clientError;
    NSURLRequest *request = [client URLRequestWithMethod:@"POST" URL:LIKE_ENDPOINT parameters:params error:&clientError];
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                NSLog(@"Like Done");
            }
            else {
                NSLog(@"Error: %@", connectionError);
            }
        }];
    }
}

+ (void)unlikeTweetWithId:(NSString *)tweetId {
    NSString *userID = [Twitter sharedInstance].sessionStore.session.userID;
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    NSDictionary *params = @{@"id" : tweetId};
    NSError *clientError;
    NSURLRequest *request = [client URLRequestWithMethod:@"POST" URL:UNLIKE_ENDPOINT parameters:params error:&clientError];
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                NSLog(@"Unlike Done");
            }
            else {
                NSLog(@"Error: %@", connectionError);
            }
        }];
    }
}

+ (void)retweetTweetWithId:(NSString *)tweetId {
    NSString *userID = [Twitter sharedInstance].sessionStore.session.userID;
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    NSDictionary *params = @{@"id" : tweetId};
    NSError *clientError;
    NSURLRequest *request = [client URLRequestWithMethod:@"POST" URL:[RETWEET_ENDPOINT stringByAppendingString:[tweetId stringByAppendingString:@".json"]] parameters:params error:&clientError];
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                NSLog(@"Retweet Done");
            }
            else {
                NSLog(@"Error: %@", connectionError);
            }
        }];
    }
}

+ (void)unretweetTweetWithId:(NSString *)tweetId {
    NSString *userID = [Twitter sharedInstance].sessionStore.session.userID;
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    NSDictionary *params = @{@"id" : tweetId};
    NSError *clientError;
    NSURLRequest *request = [client URLRequestWithMethod:@"POST" URL:[UNRETWEET_ENDPOINT stringByAppendingString:[tweetId stringByAppendingString:@".json"]] parameters:params error:&clientError];
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                NSLog(@"Unretweet Done");
            }
            else {
                NSLog(@"Error: %@", connectionError);
            }
        }];
    }
}

@end
