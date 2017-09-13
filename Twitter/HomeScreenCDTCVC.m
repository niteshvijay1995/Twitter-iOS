//
//  TweetsCDHSCVC.m
//  Twitter
//
//  Created by nitesh.vi on 07/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "HomeScreenCDTCVC.h"
#import "Tweet+CoreDataClass.h"
#import "TweetCollectionViewCell.h"
#import <TwitterKit/TwitterKit.h>
#import "TwitterFetcher.h"
#import "TwitterTweet.h"
#import "TwitterUser.h"
#import "CoreDataController.h"
#import "AppDelegate.h"
#import "Me+MeParser.h"
#import "DownloaderQueue.h"
#import "ImageCache.h"
#import "Notifications.h"
#import "NewTweetView.h"

#define maxTweetCountToFetch @"200"

@interface HomeScreenCDTCVC()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *profileImageButton;

@end

@implementation HomeScreenCDTCVC

- (void)awakeFromNib {
    [super awakeFromNib];

    self.debug = YES;
    self.managedObjectContext = [CoreDataController sharedInstance].managedObjectContext;
    
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(startHomeTimelineFetch:) userInfo:nil repeats:YES];
    [self startHomeTimelineFetch];
    [self configureProfileImageButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setProfileImage];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setProfileImage) name:UserProfileAvailabilityNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UserProfileAvailabilityNotification object:nil];
    [super viewDidDisappear:animated];
}

- (void)configureProfileImageButton {
    UIButton *imageButton = [[UIButton alloc] init];
    imageButton.layer.masksToBounds = YES;
    imageButton.clipsToBounds = YES;
    imageButton.frame = CGRectMake(0, 0,32, 32);
    imageButton.layer.cornerRadius = 0.5 * imageButton.bounds.size.height;
    self.profileImageButton.customView = imageButton;
}

- (void)setProfileImage {
    Me *meUser = ((AppDelegate *)[UIApplication sharedApplication].delegate).meUser;
    if (meUser) {
        NSOperationQueue *imageDownloaderQueue = [[DownloaderQueue sharedInstance] getImageDownloaderQueue];
        NSURL *profileImageUrl = [[NSURL alloc] initWithString:meUser.profileImageUrl];
        UIImage *profileImage = [[ImageCache sharedInstance] getCachedImageForKey:profileImageUrl.absoluteString];
        if (profileImage) {
            profileImage = [profileImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [(UIButton *)self.profileImageButton.customView setImage:profileImage forState:UIControlStateNormal];
            }
        else {
            [imageDownloaderQueue addOperationWithBlock:^{
                NSData * imageData = [[NSData alloc] initWithContentsOfURL: profileImageUrl];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [[ImageCache sharedInstance] cacheImage:image forKey:profileImageUrl.absoluteString];
                    UIImage *profileImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    [(UIButton *)self.profileImageButton.customView setImage:profileImage forState:UIControlStateNormal];
                }];
            }];
        }
    }
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    //request.fetchLimit = 30;
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO selector:@selector(localizedStandardCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

static NSString * const reuseIdentifier = @"TweetCell";

- (void)startHomeTimelineFetch:(NSTimer *)timer {
    [self startHomeTimelineFetch];
}

- (void)startRefresh {
    if (!self.refreshControl.refreshing) {
        [self startHomeTimelineFetch];
    }
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
                    [self.refreshControl endRefreshing];
                }
            }
            else {
                NSLog(@"Error: %@", connectionError);
                [self.refreshControl endRefreshing];
            }
        }];
    }
    else {
        NSLog(@"Error: %@", clientError);
        [self.refreshControl endRefreshing];
    }
}

- (IBAction)composeTweet:(id)sender {
    NewTweetView *newTweetViewController = [[NewTweetView alloc] init];
    [self presentViewController:newTweetViewController animated:YES completion:nil];
}

@end
