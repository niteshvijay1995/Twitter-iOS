//
//  NewTweetView.m
//  Twitter
//
//  Created by nitesh.vi on 05/09/17.
//  Copyright © 2017 TNET. All rights reserved.
//

#import "NewTweetView.h"

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
    [self.tweetTextView becomeFirstResponder];
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    self.tweetTextView.delegate = self;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
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
}

- (IBAction)close:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
