//
//  QueueViewController.m
//  GroupMusic
//
//
//  Created by Parker Allen Tew on 4/2/13.
//  Copyright (c) 2013 Parker Allen Tew. All rights reserved.
//


#import "QueueViewController.h"

@interface QueueViewController ()

- (IBAction)leaveEvent:(UIBarButtonItem *)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addSongButton;
@property (strong, nonatomic) UIBarButtonItem *cancelDeleteButton;
@property (nonatomic, weak) UIActionSheet *songActionSheet;
@property (nonatomic, weak) UIActionSheet *mediaActionSheet;
@property (nonatomic, strong) NSIndexPath *currentlySelectedSongIndex;
@property (strong, nonatomic) UISwipeGestureRecognizer* deleteGestureRecognizer;
@property (strong, nonatomic) NSIndexPath *cellToDelete;
@property (strong, nonatomic) SpotifyConnection *loginConnection;
@property (strong, nonatomic) SPLoginViewController *spLoginController;

- (IBAction)showMediaPicker:(id)sender;
- (void) cancelDelete;
@end


@implementation QueueViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[GroupQClient sharedClient] setDelegate:self];
    [[GroupQClient sharedClient].queue setDelegate:self];
    
    self.deleteGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightFrom:)];
    self.deleteGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self setEditing:TRUE animated:TRUE];
    
    if ([[GroupQClient sharedClient] isDJ]) {
        [self.view addGestureRecognizer:self.deleteGestureRecognizer];
    }
    self.cancelDeleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelDelete)];
    self.cellToDelete = nil;
}

- (void)viewDidAppear:(BOOL)animated{
    [[GroupQClient sharedClient] setDelegate:self];
    [self.tableView reloadData];
}

- (void)handleSwipeRightFrom:(UIGestureRecognizer *)recognizer{
    CGPoint touchPoint = [recognizer locationOfTouch:0 inView:self.view];
    self.cellToDelete = [self.tableView indexPathForRowAtPoint:touchPoint];
    if (self.cellToDelete.section == 0) {
        self.cellToDelete = nil;
    }
    else {
        self.navigationItem.rightBarButtonItem = self.cancelDeleteButton;
        [self.tableView reloadData];
    }
}

#pragma mark groupQ Queue delegate methods

- (void) queueDidChange{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    //section for now playing and annother for the rest of the queue.
    return 2;
}

/*
 Takes the integer of the section and determines how many cells there are in that section.
 If it is section 0 (Now playing) there is 1 cell.
 Otherwise the fuction returns the number of songs in the queue. 
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return [GroupQClient sharedClient].queue.queuedSongs.count;
    }
    return 0;
}

/*
 This method takes in the TableView that the cells are being created for and the index of the cell and creates
 the cell object that will be placed at that index. 
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Objective C Penis stuff
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    //Sets the inital labels so the user knows to add songs to play.
    NSString *nowPlayingTitle = @"Add a song to play.";
    if (![[GroupQClient sharedClient] isDJ]) {
        nowPlayingTitle = @"Request songs to play.";
    }
    NSString *nowPlayingSubtitle = @"";
    for (UIView *view in cell.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel*)view;
            if (label.tag == 10) {
               [label removeFromSuperview];
                break;
            }
        }
    }
    if (indexPath.section == 0){
        //handles the now playing cell if the now playing song is an ios song.
        if ([[GroupQClient sharedClient].queue.nowPlaying isKindOfClass:[iOSQueueItem class]]) {
            iOSQueueItem * song = [GroupQClient sharedClient].queue.nowPlaying;
            if (song) {
                nowPlayingTitle = song.title;
                if ([song.album isEqualToString:@""]) {
                    nowPlayingSubtitle = song.artist;
                }
                else{
                    nowPlayingSubtitle = [NSString stringWithFormat:@"%@ - %@",song.artist, song.album];
                }
            }
        }
        else if ([[GroupQClient sharedClient].queue.nowPlaying isKindOfClass:[SpotifyQueueItem class]]){
            SpotifyQueueItem *song = [GroupQClient sharedClient].queue.nowPlaying;
            NSString * title   = song.title;
            NSString * album   = song.album;
            NSString * artist  = song.artist;
            if (song) {
                nowPlayingTitle = title;
                if ([album isEqualToString:@""]) {
                    nowPlayingSubtitle = artist;
                }
                else{
                    nowPlayingSubtitle = [NSString stringWithFormat:@"%@ - %@",artist, album];
                }
            }
        }
    }
    else if(indexPath.section == 1) {
        //handles the now playing cell if the now playing song is an ios song.
        if ([[[GroupQClient sharedClient].queue.queuedSongs objectAtIndex:indexPath.row] isKindOfClass:[iOSQueueItem class]]) {
            iOSQueueItem * song = [[GroupQClient sharedClient].queue.queuedSongs objectAtIndex:indexPath.row];
            if (song) {
                nowPlayingTitle = song.title;
                if ([song.album isEqualToString:@""]) {
                    nowPlayingSubtitle = song.artist;
                }
                else{
                    nowPlayingSubtitle = [NSString stringWithFormat:@"%@ - %@",song.artist, song.album];
                }
            }
        }
        else if ([[[GroupQClient sharedClient].queue.queuedSongs objectAtIndex:indexPath.row] isKindOfClass:[SpotifyQueueItem class]]){
            SpotifyQueueItem *song = [[GroupQClient sharedClient].queue.queuedSongs objectAtIndex:indexPath.row];
            NSString * title   = song.title;
            NSString * album   = song.album;
            NSString * artist  = song.artist;
            if (song) {
                nowPlayingTitle = title;
                if ([album isEqualToString:@""]) {
                    nowPlayingSubtitle = artist;
                }
                else{
                    nowPlayingSubtitle = [NSString stringWithFormat:@"%@ - %@",artist, album];
                }
            }
        }
        UILabel *countLabel = [[UILabel alloc] init];
        countLabel.tag = 10;
        countLabel.text = [NSString stringWithFormat:@"%d", indexPath.row+1];
        countLabel.frame = CGRectMake(15, cell.frame.size.height/4, 20, cell.frame.size.height/2);
        [cell addSubview:countLabel];
    }
    cell.textLabel.text = nowPlayingTitle;
    cell.detailTextLabel.text = nowPlayingSubtitle;
    
    if(![[GroupQClient sharedClient] isDJ]) {
        cell.userInteractionEnabled = false;
    }
    
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Now Playing";
    }
    else if (section == 1) {
        return @"Up Next";
    }
    return @"";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==1) {
        self.currentlySelectedSongIndex = indexPath;
        if (self.songActionSheet) {
            // do nothing
        } else {
            UIActionSheet *songActionSheet = [[UIActionSheet alloc] initWithTitle:@"Queue Item Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Play Now",@"Play Next", nil];
            [songActionSheet showInView:[self.tableView window]];
        }
    
        [self.tableView reloadData];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![[GroupQClient sharedClient] isDJ])
        return NO;
    if (indexPath.section == 0) // Don't move the first row
       return NO;
    
    return YES;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    self.cellToDelete = nil;
    if (![[GroupQClient sharedClient] isDJ]) {
        return;
    }
    //Does not allow movement of the first section. ie section 0.
    if (sourceIndexPath.section == 1 && destinationIndexPath.section == 1){
        [[GroupQClient sharedClient] tellServerToMoveSongFrom:sourceIndexPath.row To:destinationIndexPath.row];
    }
    //make the moved song the now playing song and delete the song that is now playing.
    else if(sourceIndexPath.section == 1 && destinationIndexPath.section == 0){
        [[GroupQClient sharedClient] tellServerToPlaySong:sourceIndexPath.row];
    }
    else{
        [self.tableView moveRowAtIndexPath:destinationIndexPath toIndexPath:sourceIndexPath];
    }
    [self.tableView reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.cellToDelete isEqual:indexPath]){
        return UITableViewCellEditingStyleDelete;
    } else{
        return UITableViewCellEditingStyleNone;
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.cellToDelete = nil;
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([choice isEqualToString:@"Play Now"]){
        [[GroupQClient sharedClient] tellServerToPlaySong:self.currentlySelectedSongIndex.row];
    }
    else if([choice isEqualToString:@"Play Next"]){
        [[GroupQClient sharedClient] tellServerToMoveSongFrom:self.currentlySelectedSongIndex.row To:0];
    }
    else if([choice isEqualToString:@"Add Content"] || [choice isEqualToString:@"Request Content"]){
        [self performSegueWithIdentifier:@"addSongPicker" sender:self];
    }
    else if([choice isEqualToString:@"Add from Spotify"] || [choice isEqualToString:@"Request from Spotify"]){
        [self performSegueWithIdentifier:@"spotifySearch" sender:self];
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

/*
 This function is envoked when the user wants to add songs from the host's ios library
 */
- (IBAction)showMediaPicker:(id)sender {
    if (self.mediaActionSheet) {
        // do nothing
    } else {
        //Only adds the spotify option if the server is logged into spotify.
        NSString *spotifyTitle = nil;
        if ([[GroupQClient sharedClient] hostHasSpotify]) {
            if ([[GroupQClient sharedClient] isDJ]) {
                spotifyTitle = @"Add from Spotify";
            }
            else {
                spotifyTitle = @"Request from Spotify";
            }
        }
        NSString *contentTitle = @"Request Content";
        if ([[GroupQClient sharedClient] isDJ]) {
            contentTitle = @"Add Content";
        }
        UIActionSheet *mediaActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:contentTitle, spotifyTitle, nil];
        UITabBarController *controller = (UITabBarController*)[self parentViewController].parentViewController;
        [mediaActionSheet showFromTabBar:controller.tabBar];
    }
    
    [self.tableView reloadData];
}

- (void) cancelDelete {
    self.cellToDelete = nil;
    self.navigationItem.rightBarButtonItem = self.addSongButton;
    [self.tableView reloadData];
}

#pragma mark UITableView Delegate

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }
    if([self.cellToDelete isEqual:indexPath]){
        [[GroupQClient sharedClient] tellServerToDeleteSong:indexPath.row];
        self.cellToDelete = nil;
        self.navigationItem.rightBarButtonItem = self.addSongButton;
    }
}

#pragma mark GroupQClient Delegate Methods
- (void) eventsUpdated {}
- (void) didConnectToEvent{}
- (void) didNotConnectToEvent{}
- (void) disconnectedFromEvent{
    [self.parentViewController.parentViewController performSegueWithIdentifier:@"leaveEvent" sender:self];
}
- (IBAction)leaveEvent:(UIBarButtonItem *)sender {
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
- (void) playbackDetailsReceived{}
- (void) spotifyInfoReceived {}
- (void) initialInformationReceived {}
@end
