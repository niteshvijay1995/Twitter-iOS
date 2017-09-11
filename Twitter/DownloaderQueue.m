//
//  ImageDownloaderQueue.m
//  Twitter
//
//  Created by nitesh.vi on 11/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "DownloaderQueue.h"

static DownloaderQueue *sharedInstance;

@interface DownloaderQueue()
@property (strong, nonatomic) NSOperationQueue *imageDownloaderOperationQueue;
@end

@implementation DownloaderQueue

+ (DownloaderQueue *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DownloaderQueue alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.imageDownloaderOperationQueue = [[NSOperationQueue alloc] init];
        self.imageDownloaderOperationQueue.maxConcurrentOperationCount = 4;
    }
    return self;
}

- (NSOperationQueue *)getImageDownloaderQueue {
    return self.imageDownloaderOperationQueue;
}

@end
