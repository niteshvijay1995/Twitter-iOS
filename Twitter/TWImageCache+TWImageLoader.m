//
//  TWImageCache+TWImageLoader.m
//  Twitter
//
//  Created by nitesh.vi on 13/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "TWImageCache+TWImageLoader.h"

@implementation TWImageCache (TWImageLoader)

+ (TWImageCache *)saveImage:(UIImage *)image withUrl:(NSString *)url inManagedObjectContext:(NSManagedObjectContext *)context {
    TWImageCache *twImage = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TWImageCache"];
    request.predicate = [NSPredicate predicateWithFormat:@"url = %@",url];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || error || [matches count] > 1) {
        NSLog(@"Error in TWImageCache");
        return nil;
    } else if ([matches count]){
        twImage = [matches firstObject];
    } else {
        twImage = [NSEntityDescription insertNewObjectForEntityForName:@"TWImageCache" inManagedObjectContext:context];
        twImage.url = url;
    }
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSData *urlData = [url dataUsingEncoding:NSUTF8StringEncoding];
    NSString *imagePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",[urlData base64EncodedStringWithOptions:0]]];
    NSLog(@"Image Path - %@",imagePath);
    [imageData writeToFile:imagePath atomically:NO];
    twImage.filePath = imagePath;
    [context save:NULL];
    return twImage;
}

+ (UIImage *)loadImageFromUrl:(NSString *)url fromManagedObjectContext:(NSManagedObjectContext *)context {
    UIImage *image = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TWImageCache"];
    request.predicate = [NSPredicate predicateWithFormat:@"url = %@",url];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || error || [matches count] > 1) {
        NSLog(@"Error in TWImageCache");
    } else if ([matches count]){
        TWImageCache *twImage = [matches firstObject];
        image = [UIImage imageWithContentsOfFile:twImage.filePath];
    }
    return image;
}

@end
