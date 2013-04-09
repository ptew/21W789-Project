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

@interface NowPlayingViewController : UIViewController<GroupQClientDelegate>
- (IBAction)playButton:(UIButton *)sender;
- (IBAction)nextButton:(UIButton *)sender;
- (IBAction)previousButton:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIProgressView *songProgressBar;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *artist;
@property (weak, nonatomic) IBOutlet UIButton *playButtonOutlet;

@end
