//
//  AppDelegate.h
//  Twitter
//
//  Created by nitesh.vi on 23/08/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Me+MeParser.h"
#import <TwitterKit/TwitterKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) Me *meUser;
@property (nonatomic, strong) TWTRSession *lastSession;

@end

