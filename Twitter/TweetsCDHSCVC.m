//
//  TweetsCDHSCVC.m
//  Twitter
//
//  Created by nitesh.vi on 07/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "TweetsCDHSCVC.h"
#import "Tweet+CoreDataClass.h"
#import "TweetCollectionViewCell.h"
#import "TweetDatabaseAvailability.h"
#import <TwitterKit/TwitterKit.h>
#import "TwitterFetcher.h"
#import "TwitterTweet.h"
#import "TwitterUser.h"
#import "CoreDataController.h"

#define maxTweetCountToFetch @"50"

@interface TweetsCDHSCVC()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *profileImageButton;

@end

@implementation TweetsCDHSCVC

- (void)awakeFromNib {
    [super awakeFromNib];

    ((UICollectionViewFlowLayout *)self.collectionViewLayout).estimatedItemSize = CGSizeMake(1, 1);
    self.debug = YES;
    self.managedObjectContext = [CoreDataController sharedInstance].managedObjectContext;
    
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(startHomeTimelineFetch:) userInfo:nil repeats:YES];
    //[self startHomeTimelineFetch];
    
    [self setProfileImage];
}

- (void)setProfileImage {
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    NSString *userID = store.session.userID;
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    NSDictionary *params = @{@"user_id":userID};
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:usersEndPoint parameters:params error:&clientError];
    
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                NSError *jsonError;
                NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                NSURL *profileImageUrl = [TwitterUser getProfileImageUrlForUser:userInfo];
                ;
                dispatch_queue_t imageDownloaderQ = dispatch_queue_create("ImageDownloader", NULL);
                dispatch_async(imageDownloaderQ, ^{
                    NSData * imageData = [[NSData alloc] initWithContentsOfURL:profileImageUrl];
                    UIImage *profileImage = [UIImage imageWithData:imageData];
                    profileImage = [profileImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    UIButton *imageButton = [[UIButton alloc] init];
                    imageButton.frame = CGRectMake(0, 0,32, 32);
                    [imageButton setImage:profileImage forState:UIControlStateNormal];
                    imageButton.layer.masksToBounds = YES;
                    imageButton.clipsToBounds = YES;
                    imageButton.layer.cornerRadius = 0.5 * imageButton.bounds.size.height;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.profileImageButton.customView = imageButton;
                    });
                });
            }
            else {
                NSLog(@"Error: %@", connectionError);
            }
        }];
    }
    else {
        NSLog(@"Error: %@", clientError);
    }
    
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    request.fetchLimit = 30;
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO selector:@selector(localizedStandardCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

static NSString * const reuseIdentifier = @"TweetCell";

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TweetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSLog(@"Configuring cell at indexPath - %@",indexPath);
    Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];

    [cell configureCellFromCoreDataTweet:tweet];
    NSLog(@"Configuration Done");
    return cell;
}

- (void)startHomeTimelineFetch:(NSTimer *)timer {
    [self startHomeTimelineFetch];
}

- (void)startHomeTimelineFetch {
    NSLog(@"Fetching Tweets");
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    NSString *userID = store.session.userID;

    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    
    NSDictionary *params = @{@"count":maxTweetCountToFetch};
    
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:homeTimelineEndPoint parameters:params error:&clientError];
    
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                NSManagedObjectContext *context = [CoreDataController sharedInstance].managedObjectContext;
                if (context) {
                    NSError *jsonError;
                    NSArray *tweets = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                    [context performBlock:^{
                        [Tweet laodTweetsFromTweetArray:tweets intoManagedObjectContext:context];
                        [context save:NULL];
                    }];
                }
            }
            else {
                NSLog(@"Error: %@", connectionError);
            }
        }];
    }
    else {
        NSLog(@"Error: %@", clientError);
    }
}


@end
