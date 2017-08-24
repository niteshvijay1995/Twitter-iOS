//
//  TwitterUser.m
//  Twitter
//
//  Created by nitesh.vi on 25/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "TwitterUser.h"
#import "TwitterFetcher.h"

@implementation TwitterUser

+ (BOOL)isVerifiedUser:(NSDictionary *)user {
    return [[NSString stringWithFormat:@"%@", [user valueForKey:TWITTER_USER_VERIFIED_FLAG]] isEqualToString:@"1"];
}

+ (NSString *)getUserHandleOfUser:(NSDictionary *)user {
    return [@"@" stringByAppendingString:[user valueForKey:TWITTER_USER_SCREEN_NAME]];
}

@end
