//
//  User.h
//  Twitter
//
//  Created by nitesh.vi on 18/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NVUser.h"

@interface User : NSObject <NVUser>

@property (nullable, nonatomic) NSString *fullName;
@property (nullable, nonatomic) NSString *screenName;
@property (nullable, nonatomic) NSString *profileImageUrl;
@property (nullable, nonatomic) NSString *id;

@end
