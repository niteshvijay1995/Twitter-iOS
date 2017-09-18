//
//  UserProfileZeroCVCell.h
//  Twitter
//
//  Created by nitesh.vi on 15/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileZeroCVCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userFullName;
@property (weak, nonatomic) IBOutlet UILabel *userHandle;
@end
