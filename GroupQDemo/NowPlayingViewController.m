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
- (NSString*) timeFormatted: (int) totalSeconds;
@end

@implementation NowPlayingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.playImage = [UIImage imageNamed:@"playButton"];
    self.pauseImage = [UIImage imageNamed:@"pauseButton"];
    self.progressBarTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgressBar) userInfo:nil repeats:YES];
    if (![[GroupQClient sharedClient] isDJ]) {
        self.playButtonOutlet.enabled = false;
        self.nextButtonOutlet.enabled = false;
        self.songVolume.enabled = false;
    }
	[[GroupQClient sharedClient] setDelegate:self];
    [[GroupQClient sharedClient] tellServerToSendPlaybackDetail];
}

- (void)viewDidAppear:(BOOL)animated{
    [[GroupQClient sharedClient] setDelegate:self];
    [self playbackDetailsReceived];
}

- (IBAction)volumeUpdated:(UISlider *)sender {
    [[GroupQClient sharedClient] tellServerToSetVolume:[NSNumber numberWithFloat:sender.value]];
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


- (void)updateProgressBar{
    float songDuration;
    if([[GroupQClient sharedClient] isSongPlaying]){
        if ([[GroupQClient sharedClient].queue.nowPlaying isKindOfClass:[iOSQueueItem class]]){
            songDuration = [[(iOSQueueItem*)[GroupQClient sharedClient].queue.nowPlaying playbackDuration] floatValue];
        }
        else {
            songDuration = [(SpotifyQueueItem*)[GroupQClient sharedClient].queue.nowPlaying length];
        }
        [[GroupQClient sharedClient] setSongProgress:[[GroupQClient sharedClient] songProgress]+1];
        [self.songProgressBar setProgress:([[GroupQClient sharedClient] songProgress] / songDuration)];
        self.songProgress.text = [self timeFormatted:([[GroupQClient sharedClient] songProgress])];
    }
}

#pragma mark GroupQDelegate methods

- (void) playbackDetailsReceived {
    //sets the play button be be either play or pause
    if([[GroupQClient sharedClient] isSongPlaying]){
        self.playButtonOutlet.imageView.image = self.pauseImage;
    }
    else {
        self.playButtonOutlet.imageView.image = self.playImage;
    }
    
    //sets the progress bar to be the total progress.
    float songDuration;
    float progressPercent;
    if([GroupQClient sharedClient].queue.nowPlaying == nil){
        progressPercent = 0;
        songDuration = 0;
    }
    else if ([[GroupQClient sharedClient].queue.nowPlaying isKindOfClass:[iOSQueueItem class]]){
        songDuration = [[(iOSQueueItem*)[GroupQClient sharedClient].queue.nowPlaying playbackDuration] floatValue];
        progressPercent = [[GroupQClient sharedClient] songProgress] / songDuration;
    }
    else {
        songDuration = [(SpotifyQueueItem*)[GroupQClient sharedClient].queue.nowPlaying length];
        progressPercent = [[GroupQClient sharedClient] songProgress] / songDuration;
    }
    self.songDuration.text = [self timeFormatted:songDuration];
    self.songProgress.text = [self timeFormatted:([[GroupQClient sharedClient] songProgress])];
    
    [self.songProgressBar setProgress:progressPercent];
    
    [self.songVolume setValue:[[GroupQClient sharedClient] songVolume] animated:TRUE];
    NSLog(@"Set song volume to %f", [[GroupQClient sharedClient] songVolume]);
    
    //update the artist and the track information
    if ([[GroupQClient sharedClient].queue.nowPlaying isKindOfClass:[iOSQueueItem class]]){
        self.songTitle.text = [(iOSQueueItem*)[GroupQClient sharedClient].queue.nowPlaying title];
        self.artist.text = [(iOSQueueItem*)[GroupQClient sharedClient].queue.nowPlaying artist];
    }
    else if ([[GroupQClient sharedClient].queue.nowPlaying isKindOfClass:[SpotifyQueueItem class]]){
        self.songTitle.text = [(SpotifyQueueItem*)[GroupQClient sharedClient].queue.nowPlaying title];
        self.artist.text = [(SpotifyQueueItem*)[GroupQClient sharedClient].queue.nowPlaying artist];
    }
    
    if ([[GroupQClient sharedClient] songProgress] == -1) {
        self.artist.text = @"--";
        self.songTitle.text = @"---------";
        self.songProgress.text = @"--:--";
        self.songDuration.text = @"--:--";
    }
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (void) eventsUpdated{}
- (void) didConnectToEvent{}
- (void) didNotConnectToEvent{}
- (void) disconnectedFromEvent{
    [self.parentViewController.parentViewController performSegueWithIdentifier:@"leaveEvent" sender:self];
}
- (void) initialInformationReceived{}
- (void) spotifyInfoReceived {}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([choice isEqualToString:@"End Event"]) {
        [[GroupQEvent sharedEvent] endEvent];
    }
    else if([choice isEqualToString:@"Leave Event"]) {
        [[GroupQClient sharedClient] disconnect];
        [self disconnectedFromEvent];
    }
    else if([choice isEqualToString:@"Connect To Spotify"]) {
        self.loginConnection = [[SpotifyConnection alloc] initWithParent:self];
        [self.loginConnection setDelegate:self];
        [self.loginConnection connect];
        [self performSelector:@selector(showSpotifyLogin) withObject:nil afterDelay:0.0];
    }
}

- (void) showSpotifyLogin {
    self.spLoginController = [self.loginConnection getLoginScreen];
    [self presentViewController:self.spLoginController animated:NO completion:NULL];
}

- (void)loggedInToSpotifySuccessfully{
    [[GroupQEvent sharedEvent] setSpotify:true];
    [[GroupQEvent sharedEvent] connectToSpotify];
    [[GroupQEvent sharedEvent] tellClientsAboutSpotifyStatus];
}
- (void)loggedOutOfSpotify{
    [[GroupQEvent sharedEvent] setSpotify:false];
    [[GroupQEvent sharedEvent] tellClientsAboutSpotifyStatus];
}

- (void)failedToLoginToSpotifyWithError:(NSError*)error{
    NSLog(@"A spotify login error occored");
}

- (IBAction)eventAction:(UIBarButtonItem *)sender {
    UIActionSheet *actionSheet;
    if ([[GroupQClient sharedClient] isHost]) {
        if ([[GroupQEvent sharedEvent] hasSpotify]) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"Event Host Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"End Event" otherButtonTitles:nil];
        }
        else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"Event Host Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"End Event" otherButtonTitles:@"Connect To Spotify", nil];
        }
    }
    else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Guest Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Leave Event" otherButtonTitles:nil];
    }
    UITabBarController *controller = (UITabBarController*)[self parentViewController].parentViewController;
    [actionSheet showFromTabBar:controller.tabBar];
}
@end
