//
//  ImageCache.m
//  Twitter
//
//  Created by nitesh.vi on 30/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

//  Designed on the principle Singleton Design Pattern

#import "ImageCache.h"

static ImageCache *sharedInstance;

@interface ImageCache()
@property (strong, nonatomic) NSCache *imageCache;
@end

@implementation ImageCache

+ (ImageCache *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ImageCache alloc] init];
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
