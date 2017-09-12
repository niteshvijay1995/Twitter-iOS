//
//  TwitterFetcher.h
//  Twitter
//
//  Created by nitesh.vi on 24/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import <Foundation/Foundation.h>

//Keys in top level Dictionary
#define TWITTER_USER @"users"
#define TWITTER_NEXT_CURSOR @"next_cursor_str"

//Keys in User Dictionary
#define TWITTER_USER_FULL_NAME @"name"
#define TWITTER_USER_SCREEN_NAME @"screen_name"
#define TWITTER_USER_DESCRIPTION @"description"
#define TWITTER_USER_VERIFIED_FLAG @"verified"
#define TWITTER_USER_PROFILE_IMAGE @"profile_image_url_https"
#define TWITTER_USER_ID @"id"

//Keys in Tweet Dictionary
#define TWITTER_TWEET_USER @"user"
#define TWITTER_RETWEET @"retweeted_status"
#define TWITTER_RETWEET_USER @"retweeted_status.user"
#define TWITTER_TWEET_TEXT @"text"
#define TWITTER_RETWEET_TEXT @"retweeted_status.text"
#define TWITTER_TWEET_RETWEET_STATUS @"retweeted_status"
#define TWITTER_TWEET_RETWEET_USER @"retweeted_status.user"
#define TWITTER_TWEET_URLS @"entities.urls"
#define TWITTER_TWEET_USER_MENTIONS @"entities.user_mentions"
#define TWITTER_TWEET_ID @"id"
#define TWITTER_TWEET_CREATED_AT @"created_at"
#define TWITTER_TWEET_RETWEET_COUNT @"retweet_count"
#define TWITTER_TWEET_MEDIA @"entities.media"
#define TWITTER_TWEET_MEDIA_URL @"media_url_https"
#define TWITTER_TWEET_FAVORITE_COUNT @"favorite_count"
#define TWITTER_TWEET_RETWEET_COUNT @"retweet_count"
#define TWITTER_TWEET_FAVORITED_FLAG @"favorited"
#define TWITTER_TWEET_RETWEETED_FLAG @"retweeted"

#define TWITTER_ATTACHEMENT_URL @"url"

#define RETWEET_ENDPOINT @"https://api.twitter.com/1.1/statuses/retweet/"
#define UNRETWEET_ENDPOINT @"https://api.twitter.com/1.1/statuses/unretweet/"

#define LIKE_ENDPOINT @"https://api.twitter.com/1.1/favorites/create.json"
#define UNLIKE_ENDPOINT @"https://api.twitter.com/1.1/favorites/destroy.json"

#define usersEndPoint @"https://api.twitter.com/1.1/users/show.json"

#define STATUS_UPDATE_ENDPOINT @"https://api.twitter.com/1.1/statuses/update.json"

static NSString *homeTimelineEndPoint = @"https://api.twitter.com/1.1/statuses/home_timeline.json";

#define twitterBlueColor [UIColor colorWithRed:0.29 green:0.64 blue:1 alpha:1]

@interface TwitterFetcher : NSObject
+ (BOOL)getFetchTweetWaitingFlag;
+ (void)setFetchTweetWaitingFlagTo:(BOOL)value;
@end
