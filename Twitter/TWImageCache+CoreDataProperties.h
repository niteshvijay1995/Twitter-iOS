//
//  TWImageCache+CoreDataProperties.h
//  Twitter
//
//  Created by nitesh.vi on 13/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "TWImageCache+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TWImageCache (CoreDataProperties)

+ (NSFetchRequest<TWImageCache *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *filePath;
@property (nullable, nonatomic, copy) NSString *url;

@end

NS_ASSUME_NONNULL_END
