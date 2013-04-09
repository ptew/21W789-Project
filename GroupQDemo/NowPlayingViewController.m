//
//  NowPlayingViewController.m
//  GroupQDemo
//
//  Created by T. S. Cobb on 4/8/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "NowPlayingViewController.h"

@interface NowPlayingViewController ()
@property (strong, nonatomic) NSTimer *progressBarTimer;
@end

@implementation NowPlayingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[[GroupQClient sharedClient] setDelegate:self];
    [[GroupQClient sharedClient] tellServerToSendPlaybackDetail];
    self.progressBarTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgressBar) userInfo:nil repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [[GroupQClient sharedClient] setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playButton:(id)sender {
    if ([[GroupQClient sharedClient] isSongPlaying]){
        [[GroupQClient sharedClient] tellServerToPauseSong];
    }
    else{
        [[GroupQClient sharedClient] tellServerToResumeSong];
    }
}

- (IBAction)nextButton:(UIButton *)sender {
    [[GroupQClient sharedClient]tellServerToPlaySong:0];
}

- (IBAction)previousButton:(UIButton *)sender {
}

- (void)updateProgressBar{
    float songDuration;
    if([[GroupQClient sharedClient] isSongPlaying]){
        if ([[GroupQClient sharedClient].queue.nowPlaying isKindOfClass:[iOSQueueItem class]]){
        songDuration = [[(iOSQueueItem*)[GroupQClient sharedClient].queue.nowPlaying playbackDuration] floatValue];
        }
        else {
            songDuration = [(SpotifyQueueItem*)[GroupQClient sharedClient].queue.nowPlaying length];
        }
        [self.songProgressBar setProgress:(self.songProgressBar.progress + 1.0 / songDuration)];
    }
}

#pragma mark GroupQDelegate methods

- (void) playbackDetailsReceived {
    //sets the play button be be either play or pause
    if([[GroupQClient sharedClient] isSongPlaying]){
        [self.playButtonOutlet setTitle:@"Pause" forState:UIControlStateNormal];
    }
    else {
        [self.playButtonOutlet setTitle:@"Play" forState:UIControlStateNormal];
    }
    
    //sets the progress bar to be the total progress.
    float songDuration;
    float progressPercent;
    if([GroupQClient sharedClient].queue.nowPlaying == nil){
        progressPercent = 0;
    }
    else if ([[GroupQClient sharedClient].queue.nowPlaying isKindOfClass:[iOSQueueItem class]]){
        songDuration = [[(iOSQueueItem*)[GroupQClient sharedClient].queue.nowPlaying playbackDuration] floatValue];
        progressPercent = [[GroupQClient sharedClient] songProgress] / songDuration;
        NSLog(@"Song Duration %f", songDuration);
    }
    else {
        songDuration = [(SpotifyQueueItem*)[GroupQClient sharedClient].queue.nowPlaying length];
        progressPercent = [[GroupQClient sharedClient] songProgress] / songDuration;
        NSLog(@"Song Duration %f", songDuration);
    }
    
    NSLog(@"Progress percent %f", progressPercent);
    [self.songProgressBar setProgress:progressPercent];
    
    //update the artist and the track information
    if ([[GroupQClient sharedClient].queue.nowPlaying isKindOfClass:[iOSQueueItem class]]){
        self.songTitle.text = [(iOSQueueItem*)[GroupQClient sharedClient].queue.nowPlaying title];
        self.artist.text = [(iOSQueueItem*)[GroupQClient sharedClient].queue.nowPlaying artist];
    }
    else if ([[GroupQClient sharedClient].queue.nowPlaying isKindOfClass:[SpotifyQueueItem class]]){
        self.songTitle.text = [(SpotifyQueueItem*)[GroupQClient sharedClient].queue.nowPlaying title];
        self.artist.text = [(SpotifyQueueItem*)[GroupQClient sharedClient].queue.nowPlaying artist];
    }

    //Implement volume here once the views are in place.
}

- (void) eventsUpdated{}
- (void) didConnectToEvent{}
- (void) didNotConnectToEvent{}
- (void) disconnectedFromEvent{
    [self.parentViewController performSegueWithIdentifier:@"leaveEvent" sender:self];
}
- (void) initialInformationReceived{}
- (void) spotifyInfoReceived {}
@end
