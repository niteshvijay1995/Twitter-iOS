//
//  Me+MeParser.h
//  Twitter
//
//  Created by nitesh.vi on 12/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "Me+CoreDataProperties.h"

@interface Me (MeParser)

+ (Me *)meWithUserDictionary:(NSDictionary *)userDictionary inManagedObjectContext:(NSManagedObjectContext *)context;

@end
