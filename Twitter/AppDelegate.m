//
//  AppDelegate.m
//  Twitter
//
//  Created by nitesh.vi on 23/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "AppDelegate.h"
#import "NavigationHelper.h"
#import "AppDelegate+MOC.h"
#import "Tweet+TwitterTweetParser.h"
#import "TwitterFetcher.h"
#import "CoreDataController.h"
#import "Notifications.h"

@interface AppDelegate ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation AppDelegate

static NSString *TWITTER_CONSUMER_KEY = @"wtoP0QWgr1jfYrn89l3nVodvE";
static NSString *TWITTER_CONSUMER_SECRET = @"WQohdEFydBcYXvPJFj90liiSXWwZyiyrpNnl6ssndzaEucOonN";
static NSString *SUCCESSFULLY_LOGGED_IN_VIEW_CONTROLLER_IDENTIFIER = @"";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[Twitter sharedInstance] startWithConsumerKey:TWITTER_CONSUMER_KEY consumerSecret:TWITTER_CONSUMER_SECRET];
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    self.lastSession = store.session;
    if (self.lastSession) {
        NSLog(@"User already logged in");
        [self navigateToSuccessfullyLoggedinView];
    }
    return YES;
}

- (void)navigateToSuccessfullyLoggedinView {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"HomeScreen"];
    appDelegate.window.rootViewController = viewController;
    [appDelegate.window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    return [[Twitter sharedInstance] application:app openURL:url options:options];
}


#pragma mark - Core Data

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        _managedObjectContext = [CoreDataController sharedInstance].managedObjectContext;
    }
    return _managedObjectContext;
}

- (void)fetchUserProfile {
    NSString *userID = self.lastSession.userID;
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    NSDictionary *params = @{@"user_id":userID};
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:usersEndPoint parameters:params error:&clientError];
    
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                NSError *jsonError;
                NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                self.meUser = [Me meWithUserDictionary:userInfo inManagedObjectContext:self.managedObjectContext];
                [self.managedObjectContext save:NULL];
                [[NSNotificationCenter defaultCenter] postNotificationName:UserProfileAvailabilityNotification object:self];
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

- (Me *)meUser {
    if (!_meUser) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Me"];
        if (self.lastSession) {
            request.predicate = [NSPredicate predicateWithFormat:@"id = %@", self.lastSession.userID];
            NSError *error;
            NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
            if (!matches || error || [matches count] > 1) {
                NSLog(@"Error in fetching user profile from core data");
            }
            else if ([matches count]){
                self.meUser = [matches firstObject];
            }
            else {
                [self fetchUserProfile];
            }
        }
    }
    return _meUser;
}

@end
