//
//  NavigationHelper.m
//  Twitter
//
//  Created by nitesh.vi on 23/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "NavigationHelper.h"
#import <TwitterKit/TwitterKit.h>
#import "AppDelegate.h"

@implementation NavigationHelper

+ (void)navigateToSuccessfullyLoggedinView {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"HomeScreen"];
    appDelegate.window.rootViewController = viewController;
    [appDelegate.window makeKeyAndVisible];
}

+ (void)navigateToLoginView {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginScreen"];
    appDelegate.window.rootViewController = viewController;
    [appDelegate.window makeKeyAndVisible];
}


@end
