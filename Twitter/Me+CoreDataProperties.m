//
//  Me+CoreDataProperties.m
//  Twitter
//
//  Created by nitesh.vi on 12/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "Me+CoreDataProperties.h"

@implementation Me (CoreDataProperties)

+ (NSFetchRequest<Me *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Me"];
}

@dynamic fullName;
@dynamic screenName;
@dynamic profileImageUrl;
@dynamic id;

@end
