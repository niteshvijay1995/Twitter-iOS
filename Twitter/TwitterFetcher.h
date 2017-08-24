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

//Keys in Tweet Dictionary
#define TWITTER_TWEET_USER @"user"
#define TWITTER_TWEET_TEXT @"text"


@interface TwitterFetcher : NSObject

@end
