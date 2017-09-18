//
//  TwitterUser.h
//  Twitter
//
//  Created by nitesh.vi on 25/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterUser : NSObject

+ (BOOL)isVerifiedUser:(NSDictionary *)user;
+ (NSString *)getUserHandleOfUser:(NSDictionary *)user;
+ (NSURL *)getProfileImageUrlForUser:(NSDictionary *)user;
+ (NSString *)getFullNameForUser:(NSDictionary *)user;
@end
