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
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SpotifyQueueItem.h"


@interface QueueViewController ()

@end

@implementation QueueViewController

@synthesize myPlayer;
@synthesize userMediaItemCollection;

@synthesize songActionSheet = _songActionSheet;
@synthesize currentlySelectedSong;
@synthesize mediaActionSheet =_mediaActionSheet;
@synthesize firstLoad;
@synthesize songQueue;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.clearsSelectionOnViewWillAppear = NO;
    // instantiate a music player
    myPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    
    firstLoad = TRUE;
    
    [self registerForMediaPlayerNotifications];
    
    [self setEditing:TRUE animated:TRUE];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        if (firstLoad){
            return songQueue.count;
        }
        else{
            return songQueue.count-1;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0){
        NSString *nowPlayingTitle = @"Add a song to play";
        NSString *nowPlayingSubtitle = @"";
        if ([[songQueue objectAtIndex:0] isKindOfClass:[MPMediaItem class]]) {
            MPMediaItem * song = [songQueue objectAtIndex:0];
            NSString * title   = [song valueForProperty:MPMediaItemPropertyTitle];
            NSString * album   = [song valueForProperty:MPMediaItemPropertyAlbumTitle];
            NSString * artist  = [song valueForProperty:MPMediaItemPropertyArtist];
            if (song && !firstLoad) {
                nowPlayingTitle = title;
                if ([album isEqualToString:@""]) {
                    nowPlayingSubtitle = artist;
                }
                else{
                    nowPlayingSubtitle = [NSString stringWithFormat:@"%@ - %@",artist, album];
                }
            }
        }
        else{
            NSLog(@"Spotify section 0");
        }
        cell.textLabel.text = nowPlayingTitle;
        cell.detailTextLabel.text = nowPlayingSubtitle;
    }
    else if(indexPath.section == 1) {
        
        //THIS COULD BE PROBLEM AREA FOR INDEX ISSUES
        if ([[songQueue objectAtIndex:indexPath.row] isKindOfClass:[MPMediaItem class]]) {

            MPMediaItem *song;
            if(firstLoad){
                song = [songQueue objectAtIndex:indexPath.row];
            }
            else{
                song = [songQueue objectAtIndex:indexPath.row+1];
            }
            NSString * title   = [song valueForProperty:MPMediaItemPropertyTitle];
            NSString * album   = [song valueForProperty:MPMediaItemPropertyAlbumTitle];
            NSString * artist  = [song valueForProperty:MPMediaItemPropertyArtist];
        
            if (song) {
                cell.textLabel.text = title;
                if ([album isEqualToString:@""]) {
                    cell.detailTextLabel.text = artist;
                }
                else{
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",artist, album];
                }
            }
        }else{
            NSLog(@"Spotify");
        }
            UILabel *countLabel = [[UILabel alloc] init];
            countLabel.text = [NSString stringWithFormat:@"%d", indexPath.row+1];
            countLabel.frame = CGRectMake(15, cell.frame.size.height/4, 20, cell.frame.size.height/2);
            [cell addSubview:countLabel];
    }
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    return cell;
}

// Invoked by the delegate of the media item picker when the user is finished picking music.
//		The delegate is either this class or the table view controller, depending on the
//		state of the application.
- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection {
	// Configure the music player, but only if the user chose at least one song to play
	if (mediaItemCollection) {
        
		// If there's no playback queue yet...
		if (songQueue == nil) {
            
            songQueue = [NSMutableArray arrayWithArray:mediaItemCollection.items];
            
            [myPlayer setNowPlayingItem: [songQueue objectAtIndex:0]];
            
			// apply the new media item collection as a playback queue for the music player
            //userMediaItemCollection = [MPMediaItemCollection collectionWithItems:songQueue];
        
            //[myPlayer setQueueWithItemCollection:userMediaItemCollection];
            
            // Obtain the music player's state so it can then be
            //		restored after updating the playback queue.
		} else {
            
			// Take note of whether or not the music player is playing. If it is
			//		it needs to be started again at the end of this method.
			BOOL wasPlaying = NO;
			if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
				wasPlaying = YES;
			}
			
			// Save the now-playing item and its current playback time.
			MPMediaItem *nowPlayingItem			= musicPlayer.nowPlayingItem;
			NSTimeInterval currentPlaybackTime	= musicPlayer.currentPlaybackTime;
            
			// Combine the previously-existing media item collection with the new one
			NSMutableArray *combinedMediaItems	= [[userMediaItemCollection items] mutableCopy];
			NSArray *newMediaItems				= [mediaItemCollection items];
			[combinedMediaItems addObjectsFromArray: newMediaItems];
			
            [songQueue addObjectsFromArray: newMediaItems];
            
			//[self setUserMediaItemCollection: [MPMediaItemCollection collectionWithItems: songQueue]];
            
			// Apply the new media item collection as a playback queue for the music player.
			//[musicPlayer setQueueWithItemCollection: userMediaItemCollection];
			
			// Restore the now-playing item and its current playback time.
			musicPlayer.nowPlayingItem			= nowPlayingItem;
			musicPlayer.currentPlaybackTime		= currentPlaybackTime;
			
			// If the music player was playing, get it playing again.
			if (wasPlaying) {
				[myPlayer play];
			}
		}
        [self.tableView reloadData];
        
    
	}
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
    currentlySelectedSong = indexPath;
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

// A toggle control for playing or pausing iPod library music playback, invoked
//		when the user taps the 'playBarButton' in the Navigation bar.
- (IBAction) playOrPauseMusic: (id)sender {
    
	MPMusicPlaybackState playbackState = [myPlayer playbackState];
    
	if (playbackState == MPMusicPlaybackStateStopped || playbackState == MPMusicPlaybackStatePaused) {
		[myPlayer play];
	} else if (playbackState == MPMusicPlaybackStatePlaying) {
		[myPlayer pause];
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

// Invoked when the user taps the Done button in the media item picker after having chosen
//		one or more media items to play.
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection {
    NSLog(@"Pressed Done");
	// Dismiss the media item picker.
	[self dismissModalViewControllerAnimated: YES];
	
	// Apply the chosen songs to the music player's queue.
	[self updatePlayerQueueWithMediaCollection: mediaItemCollection];
    
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated: YES];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    
    [self dismissModalViewControllerAnimated: YES];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) // Don't move the first row
       return NO;
    
    return YES;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if ([[songQueue objectAtIndex:sourceIndexPath.row+1] isKindOfClass:[MPMediaItem class]]) {
        MPMediaItem *item =[songQueue objectAtIndex:sourceIndexPath.row+1];
        [songQueue removeObjectAtIndex:sourceIndexPath.row+1];
        [songQueue insertObject:item atIndex:destinationIndexPath.row+1];
    }
    else{
        SpotifyQueueItem *item = [songQueue objectAtIndex:sourceIndexPath.row+1];
        [songQueue removeObjectAtIndex:sourceIndexPath.row+1];
        [songQueue insertObject:item atIndex:destinationIndexPath.row+1];
        NSLog(@"Item Not an IOS item");
    }
    
    //NSMutableArray *queue = [[NSMutableArray alloc] initWithArray:userMediaItemCollection.items];
    //[queue removeObject:item];
    //[queue insertObject:item atIndex:destinationIndexPath.row];
    //NSArray *queueArray = [queue copy];
    //userMediaItemCollection = [MPMediaItemCollection collectionWithItems:songQueue];
    [self.tableView reloadData];

}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([choice isEqualToString:@"Play Now"]){
        firstLoad = false;
        if ([[songQueue objectAtIndex:currentlySelectedSong.row+1] isKindOfClass:[MPMediaItem class]]) {
            MPMediaItem *item =[songQueue objectAtIndex:currentlySelectedSong.row+1];
            [songQueue removeObjectAtIndex:currentlySelectedSong.row+1];
            [songQueue removeObjectAtIndex:0];
            [songQueue insertObject:item atIndex:0];
            [myPlayer setNowPlayingItem: [songQueue objectAtIndex:0]];
            [myPlayer play];
        }
        else{
            SpotifyQueueItem *item = [songQueue objectAtIndex:currentlySelectedSong.row+1];
            [songQueue removeObjectAtIndex:currentlySelectedSong.row+1];
            [songQueue insertObject:item atIndex:0];
            NSLog(@"Item Not an IOS item");
        }
        //userMediaItemCollection = [MPMediaItemCollection collectionWithItems:songQueue];
    }
    else if([choice isEqualToString:@"Play Next"]){
        if ([[songQueue objectAtIndex:currentlySelectedSong.row+1] isKindOfClass:[MPMediaItem class]]) {
            MPMediaItem *item =[songQueue objectAtIndex:currentlySelectedSong.row+1];
            [songQueue removeObjectAtIndex:currentlySelectedSong.row+1];
            [songQueue insertObject:item atIndex:1];
        }
        else{
            SpotifyQueueItem *item = [songQueue objectAtIndex:currentlySelectedSong.row+1];
            [songQueue removeObjectAtIndex:currentlySelectedSong.row+1];
            [songQueue insertObject:item atIndex:1];
            NSLog(@"Item Not an IOS item");
        }
        
        //userMediaItemCollection = [MPMediaItemCollection collectionWithItems:songQueue];
    }
    else if([choice isEqualToString:@"Add Song"]){
        NSLog(@"Show picker");
        MPMediaPickerController *picker =
        [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
        
        picker.delegate						= self;
        picker.allowsPickingMultipleItems	= YES;
        picker.prompt						= NSLocalizedString (@"AddSongsPrompt", @"Prompt to user to choose some songs to play");
        
        [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated:YES];
        
        [self presentModalViewController: picker animated: YES];

    }
    else if([choice isEqualToString:@"Add Playlist"]){
        
    }
    else if([choice isEqualToString:@"Add from Spotify"]){
        
    }
    [self.tableView reloadData];
}

// To learn about notifications, see "Notifications" in Cocoa Fundamentals Guide.
- (void) registerForMediaPlayerNotifications {
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
	[notificationCenter addObserver: self
						   selector: @selector (handle_NowPlayingItemChanged:)
							   name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
							 object: myPlayer];
	
	[notificationCenter addObserver: self
						   selector: @selector (handle_PlaybackStateChanged:)
							   name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
							 object: myPlayer];
    
	[myPlayer beginGeneratingPlaybackNotifications];
}

- (void) handle_NowPlayingItemChanged: (NSNotification *) notification {
    NSLog(@"Got notified now playing");
}

- (void) handle_PlaybackStateChanged: (id) notification {
    NSLog(@"Got notified Playback");
    MPMusicPlaybackState playbackState = [myPlayer playbackState];
    
    if (playbackState == MPMusicPlaybackStateStopped) {
        [songQueue removeObjectAtIndex:0];
		if ([[songQueue objectAtIndex:0] isKindOfClass:[MPMediaItem class]]) {
            [myPlayer setNowPlayingItem: [songQueue objectAtIndex:0]];
            [myPlayer play];
        }
        else{
            //set the spotify item at index 0 to the currently playing item in spotify player and playf
            NSLog(@"Item Not an IOS item");
        }
    [self.tableView reloadData];
	}
}


@end
