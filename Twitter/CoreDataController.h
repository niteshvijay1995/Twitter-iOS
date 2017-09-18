//
//  CoreDataController.h
//  Twitter
//
//  Created by nitesh.vi on 08/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataController : NSObject

+ (CoreDataController *)sharedInstance;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
