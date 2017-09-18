//
//  MyProfileTweetsCollectionViewController.h
//  Twitter
//
//  Created by nitesh.vi on 14/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "TweetsCollectionViewController.h"
#import "NVUser.h"

@interface UserProfileTweetsCollectionViewController : TweetsCollectionViewController

@property (strong, nonatomic) NSObject <NVUser> *user;

@end
