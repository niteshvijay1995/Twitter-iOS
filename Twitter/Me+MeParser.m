//
//  Me+MeParser.m
//  Twitter
//
//  Created by nitesh.vi on 12/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "Me+MeParser.h"
#import "TwitterFetcher.h"
#import "TwitterUser.h"

@implementation Me (MeParser)

+ (Me *)meWithUserDictionary:(NSDictionary *)userDictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Me *me = nil;
    
    NSString *id = [NSString stringWithFormat:@"%@",[userDictionary valueForKeyPath:TWITTER_USER_ID]];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Me"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %@",id];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || [matches count] > 1) {
        NSLog(@"Error");
    } else if ([matches count]){
        me = [matches firstObject];
        [context save:NULL];
    } else {
        me = [NSEntityDescription insertNewObjectForEntityForName:@"Me" inManagedObjectContext:context];
        [self parseUserDictionary:userDictionary intoObject:me];
    }
    return me;
}

+ (User *)userWithUserDictionary:(NSDictionary *)userDictionary {
    User *user = [[User alloc] init];
    [self parseUserDictionary:userDictionary intoObject:user];
    return user;
}

+ (void)parseUserDictionary:(NSDictionary *)userDictionary intoObject:(NSObject <NVUser> *)user {
    user.id = [NSString stringWithFormat:@"%@",[userDictionary valueForKeyPath:TWITTER_USER_ID]];
    user.profileImageUrl = [userDictionary valueForKeyPath:TWITTER_USER_PROFILE_IMAGE];
    user.fullName = [userDictionary valueForKeyPath:TWITTER_USER_FULL_NAME];
    user.screenName = [userDictionary valueForKeyPath:TWITTER_USER_SCREEN_NAME];
}
@end
