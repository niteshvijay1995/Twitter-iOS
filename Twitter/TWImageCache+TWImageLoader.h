//
//  TWImageCache+TWImageLoader.h
//  Twitter
//
//  Created by nitesh.vi on 13/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "TWImageCache+CoreDataClass.h"
#import <UIKit/UIKit.h>

@interface TWImageCache (TWImageLoader)

+ (TWImageCache *)saveImage:(UIImage *)image withUrl:(NSString *)url inManagedObjectContext:(NSManagedObjectContext *)context;
+ (UIImage *)loadImageFromUrl:(NSString *)url fromManagedObjectContext:(NSManagedObjectContext *)context;

@end
