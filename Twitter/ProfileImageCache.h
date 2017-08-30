//
//  ProfileImageCache.h
//  Twitter
//
//  Created by nitesh.vi on 30/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ProfileImageCache : NSObject

+ (ProfileImageCache *)sharedInstance;

- (void)cacheImage:(UIImage *)image forKey:(NSString *)key;

- (UIImage *)getCachedImageForKey:(NSString *)key;

@end
