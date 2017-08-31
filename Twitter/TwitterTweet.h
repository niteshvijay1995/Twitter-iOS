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
@end
