//
//  TWImageCache+CoreDataProperties.m
//  Twitter
//
//  Created by nitesh.vi on 13/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "TWImageCache+CoreDataProperties.h"

@implementation TWImageCache (CoreDataProperties)

+ (NSFetchRequest<TWImageCache *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"TWImageCache"];
}

@dynamic filePath;
@dynamic url;

@end
