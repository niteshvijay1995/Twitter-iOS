//
//  ImageCache.m
//  Twitter
//
//  Created by nitesh.vi on 30/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

//  Designed on the principle Singleton Design Pattern

#import "ImageCache.h"
#import "TWImageCache+TWImageLoader.h"
#import "CoreDataController.h"
#import "DownloaderQueue.h"

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
        UIImage *imageFromCache = [self.imageCache objectForKey:key];
        if (!imageFromCache)
        {
            [self.imageCache setObject:image forKey:key];
            NSOperationQueue *operationQ = [DownloaderQueue sharedInstance].getImageDownloaderQueue;
            [operationQ addOperationWithBlock:^{
                [TWImageCache saveImage:image withUrl:key inManagedObjectContext:[CoreDataController sharedInstance].managedObjectContext];
            }];
        }
    }
}

- (UIImage *)getCachedImageForKey:(NSString *)key {
    UIImage *image = [self.imageCache objectForKey:key];
    if (!image) {
        image = [TWImageCache loadImageFromUrl:key fromManagedObjectContext:[CoreDataController sharedInstance].managedObjectContext];
        if (image) {
            [self cacheImage:image forKey:key];
        }
    }
    return image;
}
@end
