//
//  Me+CoreDataProperties.h
//  Twitter
//
//  Created by nitesh.vi on 12/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "Me+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Me (CoreDataProperties)

+ (NSFetchRequest<Me *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *fullName;
@property (nullable, nonatomic, copy) NSString *screenName;
@property (nullable, nonatomic, copy) NSString *profileImageUrl;
@property (nullable, nonatomic, copy) NSString *id;

@end

NS_ASSUME_NONNULL_END
