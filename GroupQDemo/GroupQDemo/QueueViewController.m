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
@property (nonatomic, weak) UIActionSheet *songActionSheet;
@property (nonatomic, weak) UIActionSheet *mediaActionSheet;
@property (nonatomic, strong) NSIndexPath *currentlySelectedSongIndex;

- (IBAction)showMediaPicker:(id)sender;

@end


@implementation QueueViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[GroupQClient sharedClient] setDelegate:self];
    [[GroupQClient sharedClient].queue setDelegate:self];
     self.clearsSelectionOnViewWillAppear = NO;
    [self setEditing:TRUE animated:TRUE];
}

- (void)viewDidAppear:(BOOL)animated{
    [self.tableView reloadData];
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
    NSString *nowPlayingTitle = @"Add a song to play";
    NSString *nowPlayingSubtitle = @"";
    
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
        countLabel.text = [NSString stringWithFormat:@"%d", indexPath.row+1];
        countLabel.frame = CGRectMake(15, cell.frame.size.height/4, 20, cell.frame.size.height/2);
        [cell addSubview:countLabel];
    }
    cell.textLabel.text = nowPlayingTitle;
    cell.detailTextLabel.text = nowPlayingSubtitle;
    
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
    if (indexPath.section == 0) // Don't move the first row
       return NO;
    
    return YES;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    //Does not allow movement of the first section. ie section 0.
    if (sourceIndexPath.section == 1 && destinationIndexPath.section == 1){
        [[GroupQClient sharedClient] tellServerToMoveSongFrom:sourceIndexPath.row To:destinationIndexPath.row];
    }
    //make the moved song the now playing song and delete the song that is now playing.
    else if(sourceIndexPath.section == 1 && destinationIndexPath.section == 0){
        [[GroupQClient sharedClient] tellServerToPlaySong:sourceIndexPath.row];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([choice isEqualToString:@"Play Now"]){
        [[GroupQClient sharedClient] tellServerToPlaySong:self.currentlySelectedSongIndex.row];
    }
    else if([choice isEqualToString:@"Play Next"]){
        [[GroupQClient sharedClient] tellServerToMoveSongFrom:self.currentlySelectedSongIndex.row To:0];
    }
    else if([choice isEqualToString:@"Add Content"]){
        [self performSegueWithIdentifier:@"addSongPicker" sender:self];
    }
    else if([choice isEqualToString:@"Add from Spotify"]){
        [self performSegueWithIdentifier:@"spotifySearch" sender:self];
    }
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
            spotifyTitle = @"Add from Spotify";
        }
        UIActionSheet *mediaActionSheet = [[UIActionSheet alloc] initWithTitle:@"Add Content" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add Content", spotifyTitle, nil];
        [mediaActionSheet showFromBarButtonItem:sender animated:YES];
    }
    
    [self.tableView reloadData];
}

#pragma mark GroupQClient Delegate Methods
- (void) eventsUpdated {}
- (void) didConnectToEvent{}
- (void) didNotConnectToEvent{}
- (void) disconnectedFromEvent{
    [self performSegueWithIdentifier:@"leaveEvent" sender:self];
}
- (IBAction)leaveEvent:(UIBarButtonItem *)sender {
    NSLog(@"This is %@", [[GroupQClient sharedClient].library.songCollection objectAtIndex:0]);
}
- (void) playbackDetailsReceived{}
- (void) spotifyInfoReceived {}
- (void) initialInformationReceived {}
@end
