//
//  NewTweetView.m
//  Twitter
//
//  Created by nitesh.vi on 05/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "NewTweetView.h"
#import "TwitterFetcher.h"
#import <TwitterKit/TwitterKit.h>
#import "AppDelegate.h"
#import "Me+MeParser.h"
#import "DownloaderQueue.h"
#import "ImageCache.h"
#import "Notifications.h"

@interface NewTweetView() <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerBarBottomConstraint;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UIProgressView *charactersLeftProgressBar;
@property (weak, nonatomic) IBOutlet UILabel *charactersLeftLabel;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;
@property (weak, nonatomic) IBOutlet UILabel *welcomeMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end

@implementation NewTweetView

static int MAX_TWEET_LENGTH = 140;

- (void)viewDidLoad {
    self.tweetButton.layer.cornerRadius = self.tweetButton.bounds.size.height/2;
    self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.height/2;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tweetTextView becomeFirstResponder];
    [self setProfileImage];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setProfileImage) name:UserProfileAvailabilityNotification object:nil];
    self.tweetTextView.delegate = self;
}

- (void)setProfileImage {
    Me *meUser = ((AppDelegate *)[UIApplication sharedApplication].delegate).meUser;
    if (meUser) {
        NSOperationQueue *imageDownloaderQueue = [[DownloaderQueue sharedInstance] getImageDownloaderQueue];
        NSURL *profileImageUrl = [[NSURL alloc] initWithString:meUser.profileImageUrl];
        UIImage *profileImage = [[ImageCache sharedInstance] getCachedImageForKey:profileImageUrl.absoluteString];
        if (profileImage) {
            profileImage = [profileImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            self.profileImageView.image = profileImage;
        }
        else {
            [imageDownloaderQueue addOperationWithBlock:^{
                NSData * imageData = [[NSData alloc] initWithContentsOfURL: profileImageUrl];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [[ImageCache sharedInstance] cacheImage:image forKey:profileImageUrl.absoluteString];
                    UIImage *profileImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    self.profileImageView.image = profileImage;
                }];
            }];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UserProfileAvailabilityNotification object:nil];
    [super viewWillDisappear:animated];
}

- (void)keyboardWillShow:(NSNotification *)sender {
    self.footerBarBottomConstraint.constant = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([[self.tweetTextView text] length] - range.length + text.length > MAX_TWEET_LENGTH) {
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self setCharactersLeftLabelTextUsingCount:(MAX_TWEET_LENGTH - (int)[textView.text length])];
    [self setCharactersLeftProgressBarUsingCount:(int)[textView.text length]];
    if ([textView.text length] > 0) {
        self.welcomeMessageLabel.hidden = YES;
        self.tweetButton.enabled = YES;
    }
    if ([textView.text length] == 0) {
        self.welcomeMessageLabel.hidden = NO;
        self.tweetButton.enabled = NO;
    }
}

- (void)setCharactersLeftLabelTextUsingCount:(int)count {
    self.charactersLeftLabel.text = [NSString stringWithFormat:@"%d characters left",count];
}

- (void)setCharactersLeftProgressBarUsingCount:(int)count {
    self.charactersLeftProgressBar.progress = (float)count/MAX_TWEET_LENGTH;
}

- (IBAction)tweetButtonPressed:(id)sender {
    NSString *status = self.tweetTextView.text;
    NSString *userID = [Twitter sharedInstance].sessionStore.session.userID;
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    NSDictionary *params = @{@"status" : status};
    NSError *clientError;
    NSURLRequest *request = [client URLRequestWithMethod:@"POST" URL:STATUS_UPDATE_ENDPOINT parameters:params error:&clientError];
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                NSLog(@"Status update Done");
                [self close:nil];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                                message:@"You must be connected to the internet"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                NSLog(@"Error: %@", connectionError);
            }
        }];
    }
}

- (IBAction)close:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
