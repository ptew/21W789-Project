//
//  NowPlayingViewController.h
//  GroupQDemo
//
//  Created by T. S. Cobb on 4/8/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupQQueue.h"
#import "GroupQClient.h"

@interface NowPlayingViewController : UIViewController<GroupQClientDelegate, SpotifyConnectionDelegate, UIActionSheetDelegate>
- (IBAction)volumeUpdated:(UISlider *)sender;
- (IBAction)playButton:(UIButton *)sender;
- (IBAction)nextButton:(UIButton *)sender;
- (IBAction)eventAction:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIProgressView *songProgressBar;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *artist;
@property (weak, nonatomic) IBOutlet UIButton *playButtonOutlet;
@property (weak, nonatomic) IBOutlet UILabel *songDuration;
@property (weak, nonatomic) IBOutlet UILabel *songProgress;
@property (weak, nonatomic) IBOutlet UISlider *songVolume;
@property (strong, nonatomic) UIImage *playImage;
@property (strong, nonatomic) UIImage *pauseImage;
@property (strong, nonatomic) SpotifyConnection *loginConnection;
@property (strong, nonatomic) SPLoginViewController *spLoginController;
@end
