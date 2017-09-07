//
//  AppDelegate.m
//  Twitter
//
//  Created by nitesh.vi on 23/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "AppDelegate.h"
#import <TwitterKit/TwitterKit.h>
#import "NavigationHelper.h"
#import "AppDelegate+MOC.h"
#import "Tweet+TwitterTweetParser.h"
#import "TwitterFetcher.h"
#import "TweetDatabaseAvailability.h"

@interface AppDelegate () <NSURLSessionDownloadDelegate>

@property (copy, nonatomic) void (^twitterDownloadBackgroudURLSessionCompletionHandler)();
@property (strong, nonatomic) NSURLSession *twitterDownloadSession;
@property (strong, nonatomic) NSTimer *twitterForegroundFetchTimer;
@property (strong, nonatomic) NSManagedObjectContext *tweetDatabaseContext;

@end

#define TWITTER_FETCH @"Twitter Just Uploaded Fetch"

#define FOREGROUND_TWITTER_FETCH_INTERVAL (20)


@implementation AppDelegate

static NSString *TWITTER_CONSUMER_KEY = @"wtoP0QWgr1jfYrn89l3nVodvE";
static NSString *TWITTER_CONSUMER_SECRET = @"WQohdEFydBcYXvPJFj90liiSXWwZyiyrpNnl6ssndzaEucOonN";
static NSString *SUCCESSFULLY_LOGGED_IN_VIEW_CONTROLLER_IDENTIFIER = @"";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[Twitter sharedInstance] startWithConsumerKey:TWITTER_CONSUMER_KEY consumerSecret:TWITTER_CONSUMER_SECRET];
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    TWTRSession *lastSession = store.session;
    if (lastSession) {
        NSLog(@"User already logged in");
        self.tweetDatabaseContext = [self createMainQueueManagedObjectContext];
        [self startTwitterFetch];
        //[self navigateToSuccessfullyLoggedinView];
    }
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [self startTwitterFetch];
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    self.twitterDownloadBackgroudURLSessionCompletionHandler = completionHandler;
}

- (void)setTweetDatabaseContext:(NSManagedObjectContext *)tweetDatabaseContext {
    _tweetDatabaseContext = tweetDatabaseContext;
    
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(startTwitterFetch:) userInfo:nil repeats:YES];
    
    NSDictionary *userInfo = self.tweetDatabaseContext ? @{ TweetDatabaseAvailabilityContext : self.tweetDatabaseContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:TweetDatabaseAvailabilityNotification object:self userInfo:userInfo];
}

- (void)startTwitterFetch:(NSTimer *)timer {
    [self startTwitterFetch];
}

- (void)navigateToSuccessfullyLoggedinView {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"HomeScreen"];
    appDelegate.window.rootViewController = viewController;
    [appDelegate.window makeKeyAndVisible];
}

- (void)startTwitterFetch {
    [self.twitterDownloadSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        if (![downloadTasks count]) {
            TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
            NSString *userID = store.session.userID;
            
            TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
            
            //NSString *since_id = [TwitterTweet getTweetIDForTweet:[self.tweetList firstObject]];
            NSDictionary *params = @{@"count":@"40"};
            
            NSError *clientError;
            
            NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:homeTimelineEndPoint parameters:params error:&clientError];
            NSURLSessionDownloadTask *task = [self.twitterDownloadSession downloadTaskWithRequest:request];
            task.taskDescription = TWITTER_FETCH;
            [task resume];
        } else {
            for (NSURLSessionDownloadTask *task in downloadTasks) [task resume];
        }
    }];
}

- (NSURLSession *)twitterDownloadSession {
    if (!_twitterDownloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:TWITTER_FETCH];
            urlSessionConfig.allowsCellularAccess = NO;
            _twitterDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig delegate:self delegateQueue:nil];
        });
    }
    return _twitterDownloadSession;
}

- (NSArray *)tweetsAtURL:(NSURL *)url {
    NSData *twitterJSONData = [NSData dataWithContentsOfURL:url];
    NSArray *tweets = [NSJSONSerialization JSONObjectWithData:twitterJSONData options:0 error:NULL];
    return tweets;
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(nonnull NSURL *)location {
    if ([downloadTask.taskDescription isEqualToString:TWITTER_FETCH]) {
        NSManagedObjectContext *context = self.tweetDatabaseContext;
        if (context) {
            if (location) {
                NSArray *tweets = [self tweetsAtURL:location];
                [context performBlock:^{
                    [Tweet laodTweetsFromTweetArray:tweets intoManagedObjectContext:context];
                    [context save:NULL];
            }];
            }
        } else {
            //[self twitterDownloadTasksMightBeComplete];
        }
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
}

- (void)twitterDownloadTasksMightBeComplete {
    if (self.twitterDownloadBackgroudURLSessionCompletionHandler) {
        [self.twitterDownloadSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
            if (![downloadTasks count]) {
                void (^completionHandler)() = self.twitterDownloadBackgroudURLSessionCompletionHandler;
                self.twitterDownloadBackgroudURLSessionCompletionHandler = nil;
                if (completionHandler) {
                    completionHandler();
                }
            }
        }];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    return [[Twitter sharedInstance] application:app openURL:url options:options];
}

@end
