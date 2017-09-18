//
//  ImageDownloaderQueue.h
//  Twitter
//
//  Created by nitesh.vi on 11/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloaderQueue : NSObject

+ (DownloaderQueue *)sharedInstance;
- (NSOperationQueue *)getImageDownloaderQueue;

@end
