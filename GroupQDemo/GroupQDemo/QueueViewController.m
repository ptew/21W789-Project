//
//  QueueViewController.m
//  GroupMusic
//
//
//  Created by Parker Allen Tew on 4/2/13.
//  Copyright (c) 2013 Parker Allen Tew. All rights reserved.
//

/*
    Things left to do:
        -null currently playing when selecting a song that is playing
        -do we want to be able to add song multiple times to queue?
        -adding entire playlist
*/


#import "QueueViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Spotify.h"


@interface QueueViewController ()

//@property (nonatomic, strong)	MPMediaItemCollection	*userMediaItemCollection;
- (IBAction)leaveEvent:(UIBarButtonItem *)sender;
@property (nonatomic, weak) UIActionSheet *songActionSheet;
@property (nonatomic, weak) UIActionSheet *mediaActionSheet;
@property (nonatomic, strong) NSIndexPath *currentlySelectedSong;
@property (nonatomic, strong) GroupQQueue *songQueue;

- (IBAction)showMediaPicker:(id)sender;

@end

@implementation QueueViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[GroupQClient sharedClient] setDelegate:self];
     self.clearsSelectionOnViewWillAppear = NO;
    [self setEditing:TRUE animated:TRUE];
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
        if ([[GroupQClient sharedClient].queue.nowPlaying isKindOfClass:[MPMediaItem class]]) {
            MPMediaItem * song = [GroupQClient sharedClient].queue.nowPlaying;
            NSString * title   = [song valueForProperty:MPMediaItemPropertyTitle];
            NSString * album   = [song valueForProperty:MPMediaItemPropertyAlbumTitle];
            NSString * artist  = [song valueForProperty:MPMediaItemPropertyArtist];
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
        if ([[[GroupQClient sharedClient].queue.queuedSongs objectAtIndex:indexPath.row] isKindOfClass:[MPMediaItem class]]) {
            MPMediaItem * song = [[GroupQClient sharedClient].queue.queuedSongs objectAtIndex:indexPath.row];
            NSString * title   = [song valueForProperty:MPMediaItemPropertyTitle];
            NSString * album   = [song valueForProperty:MPMediaItemPropertyAlbumTitle];
            NSString * artist  = [song valueForProperty:MPMediaItemPropertyArtist];
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
        else if ([[[GroupQClient sharedClient].queue.queuedSongs objectAtIndex:indexPath.row] isKindOfClass:[SpotifyQueueItem class]]){
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

// Invoked by the delegate of the media item picker when the user is finished picking music.
//		The delegate is either this class or the table view controller, depending on the
//		state of the application.
- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection {
	// Configure the music player, but only if the user chose at least one song to play
/*	if (mediaItemCollection) {
        
		// If there's no playback queue yet...
		if (self.songQueue == nil) {
            
            self.songQueue = [NSMutableArray arrayWithArray:mediaItemCollection.items];
            
       		// apply the new media item collection as a playback queue for the music player
            //userMediaItemCollection = [MPMediaItemCollection collectionWithItems:songQueue];
        
            //[myPlayer setQueueWithItemCollection:userMediaItemCollection];
            
            // Obtain the music player's state so it can then be
            //		restored after updating the playback queue.
		} else {			
			// Save the now-playing item and its current playback time.
			MPMediaItem *nowPlayingItem			= self.myPlayer.nowPlayingItem;
			NSTimeInterval currentPlaybackTime	= self.myPlayer.currentPlaybackTime;
            
			// Combine the previously-existing media item collection with the new one
			NSMutableArray *combinedMediaItems	= [[self.userMediaItemCollection items] mutableCopy];
			NSArray *newMediaItems				= [mediaItemCollection items];
			[combinedMediaItems addObjectsFromArray: newMediaItems];
			
            [self.songQueue addObjectsFromArray: newMediaItems];
            
			//[self setUserMediaItemCollection: [MPMediaItemCollection collectionWithItems: songQueue]];
            
			// Apply the new media item collection as a playback queue for the music player.
			//[musicPlayer setQueueWithItemCollection: userMediaItemCollection];
			
			// Restore the now-playing item and its current playback time.
			self.myPlayer.nowPlayingItem			= nowPlayingItem;
			self.myPlayer.currentPlaybackTime		= currentPlaybackTime;
			
			// If the music player was playing, get it playing again.
			if (wasPlaying) {
				[self.myPlayer play];
			}
		}
        [self.tableView reloadData];
        
    
	}
*/
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
    self.currentlySelectedSong = indexPath;
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
    [[GroupQClient sharedClient] tellServerToMoveSongFrom:sourceIndexPath.row To:destinationIndexPath.row];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([choice isEqualToString:@"Play Now"]){
        [[GroupQClient sharedClient] tellServerToPlaySong:self.currentlySelectedSong.row];
    }
    else if([choice isEqualToString:@"Play Next"]){
        [[GroupQClient sharedClient] tellServerToMoveSongFrom:self.currentlySelectedSong.row To:0];
    }
    else if([choice isEqualToString:@"Add Song"]){
        [[GroupQClient sharedClient] tellServerToAddSongs:[MPMediaItemCollection collectionWithItems:[[MPMediaQuery songsQuery].items objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 10)]]]];
        [self performSegueWithIdentifier:@"addSongPicker" sender:self];
    }
    else if([choice isEqualToString:@"Add Playlist"]){
        ///////////////////////////////////////////////////////
        ////////FOR PARKER TO IMPLEMENT///////////////////////
        //////////////////////////////////////////////////////
        
    }
    else if([choice isEqualToString:@"Add from Spotify"]){
        ///////////////////////////////////////////////////////
        ////////Open Spotify Search view///////////////////////
        ////////For Brad to Implement/////////////////////////
        //////////////////////////////////////////////////////
    }
}

- (IBAction)showMediaPicker:(id)sender {
    if (self.mediaActionSheet) {
        // do nothing
    } else {
        UIActionSheet *mediaActionSheet = [[UIActionSheet alloc] initWithTitle:@"Add Content" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add Song",@"Add Playlist", @"Add from Spotify", nil];
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
}
@end
