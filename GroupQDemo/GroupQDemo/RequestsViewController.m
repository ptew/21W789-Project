//
//  RequestsViewController.m
//  GroupQDemo
//
//  Created by Jono Matthews on 4/27/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "RequestsViewController.h"

@interface RequestsViewController ()

@property int currentlySelectedSongIndex;

@end

@implementation RequestsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [[GroupQClient sharedClient] setDelegate:self];
    [[[GroupQClient sharedClient] requestQueue] setDelegate:self];
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
    [[GroupQClient sharedClient] setDelegate:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[GroupQClient sharedClient] requestQueue] queuedSongs].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSString *songTitle;
    NSString *songDetail;
    
    id song = [[[[GroupQClient sharedClient] requestQueue] queuedSongs] objectAtIndex:indexPath.row];
    if ([song isKindOfClass:[iOSQueueItem class]]) {
        iOSQueueItem *iOSSong = song;
        songTitle = iOSSong.title;
        if ([iOSSong.album isEqualToString:@""]) {
            songDetail = iOSSong.artist;
        }
        else{
            songDetail = [NSString stringWithFormat:@"%@ - %@",iOSSong.artist, iOSSong.album];
        }
    }
    else {
        SpotifyQueueItem *spotifySong = song;
        songTitle = spotifySong.title;
        if ([spotifySong.album isEqualToString:@""]) {
            songDetail = spotifySong.artist;
        }
        else{
            songDetail = [NSString stringWithFormat:@"%@ - %@",spotifySong.artist, spotifySong.album];
        }
    }
    cell.textLabel.text = songTitle;
    cell.detailTextLabel.text = songDetail;
    
    if(![[GroupQClient sharedClient] isDJ]) {
        cell.userInteractionEnabled = false;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentlySelectedSongIndex = indexPath.row;
    UIActionSheet *songActionSheet = [[UIActionSheet alloc] initWithTitle:@"Song Request Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Reject Request" otherButtonTitles:@"Add To Queue", nil];
    [songActionSheet showInView:[self.tableView window]];
}

#pragma mark - Action sheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([choice isEqualToString:@"Add To Queue"]){
        NSArray *songList = [NSArray arrayWithObject:[[[[GroupQClient sharedClient] requestQueue] queuedSongs] objectAtIndex: self.currentlySelectedSongIndex]];
        [[GroupQClient sharedClient] tellServerToAddSongs:songList];
        [[GroupQClient sharedClient] tellServerToDeleteRequest:self.currentlySelectedSongIndex];
    }
    else if([choice isEqualToString:@"Reject Request"]) {
        [[GroupQClient sharedClient] tellServerToDeleteRequest:self.currentlySelectedSongIndex];
    }
    else if([choice isEqualToString:@"End Event"]) {
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

- (void) playbackDetailsReceived {}

#pragma mark - Spotify and event delegate

- (void) eventsUpdated{}
- (void) didConnectToEvent{}
- (void) didNotConnectToEvent{}
- (void) disconnectedFromEvent{
    [self.parentViewController.parentViewController performSegueWithIdentifier:@"leaveEvent" sender:self];
}
- (void) initialInformationReceived{}
- (void) spotifyInfoReceived {}


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

// Queue delegate
- (void) queueDidChange {
    [self.tableView reloadData];
}


@end
