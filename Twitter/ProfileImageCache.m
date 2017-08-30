//
//  ProfileImageCache.m
//  Twitter
//
//  Created by nitesh.vi on 30/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

//  Designed on the principle Singleton Design Pattern

#import "ProfileImageCache.h"

static ProfileImageCache *sharedInstance;

@interface ProfileImageCache()
@property (strong, nonatomic) NSCache *imageCache;
@end

@implementation ProfileImageCache

+ (ProfileImageCache *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ProfileImageCache alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.imageCache = [[NSCache alloc] init];
    }
    return self;
}

- (void)cacheImage:(UIImage *)image forKey:(NSString *)key {
    if (image != nil && key != nil) {
        [self.imageCache setObject:image forKey:key];
    }
}

- (UIImage *)getCachedImageForKey:(NSString *)key {
    return [self.imageCache objectForKey:key];
}
@end
