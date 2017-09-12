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

@interface AppDelegate ()

@end

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
