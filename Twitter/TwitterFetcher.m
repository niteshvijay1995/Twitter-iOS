//
//  TwitterFetcher.m
//  Twitter
//
//  Created by nitesh.vi on 24/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "TwitterFetcher.h"

@implementation TwitterFetcher

static BOOL fetchTweetWaitingFlag = NO;

+ (BOOL)getFetchTweetWaitingFlag {
    return fetchTweetWaitingFlag;
}

+ (void)setFetchTweetWaitingFlagTo:(BOOL)value {
    fetchTweetWaitingFlag = value;
}
@end


