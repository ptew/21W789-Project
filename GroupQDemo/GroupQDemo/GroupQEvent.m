//
//  GroupQEvent.m
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/4/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//


#import "GroupQEvent.h"

// Socket callback forward declaration -- see description in implementation
void socketCallBack(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info);

@interface GroupQEvent () {
    uint16_t port;          // The event's port
    CFSocketRef socketRef;  // The listening socket of the event
    
    NSTimeInterval pauseTime;
    bool isSongPlaying;
}

// The music player
@property (strong, nonatomic) MPMusicPlayerController *musicPlayer;
// The current music item being played
@property (strong, nonatomic) MPMediaItem *nowPlayingHandle;


// The song queue and library
@property (strong, nonatomic) GroupQQueue *songQueue;
@property (strong, nonatomic) GroupQMusicCollection *library;

// Event creation
- (void) setupListeningSocket;
- (void) broadcastEvent;

// Queue and player management
- (void) setupMusicPlayer;
- (void) playNextSongInQueue;

// Handles new connections
- (void)handleNewNativeSocket:(CFSocketNativeHandle)nativeSocketHandle;


// Functions for sending messages to clients
- (void) broadcastMessage: (NSString *) message withHeader: (NSString *) header;
- (void) broadcastObject: (id) object withHeader: (NSString *) header;

// Event information
- (void) sendItemsAndQueueTo: (GroupQConnection *) who;
- (void) tellClientsPlaybackDetails;

// Queue management
- (void) tellClientsToAddSongs: (NSArray *) songs;
- (void) tellClientsToMoveSongFrom: (int) oldPos to: (int) newPos;
- (void) tellClientsToDeleteSong: (int) position;
- (void) tellClientsToPlaySong: (int) position;
- (void) tellClientsToAddSpotifySong: (SpotifyQueueItem *) song;
@end


@implementation GroupQEvent

#pragma mark - Event initialization and closing

- (GroupQEvent*) init {
    self = [super init];
    hasSpotify = false;
    return self;
}
- (void) createEventWithName: (NSString*) name andPassword: (NSString*) password {
    // Store the event name and set up the user list
    self.eventName = name;
    self.eventPassword = password;
    self.userConnections = [[NSMutableArray alloc] init];
    
    [self setupMusicPlayer];
    
    [self setupListeningSocket];
    
    [self broadcastEvent];
}

- (void) setupListeningSocket {
    // Create an empty listening socket -- give it a pointer to this event for callback purposes
    CFSocketContext socketCtxt = {0, (__bridge void *)(self), NULL, NULL, NULL};
    socketRef = CFSocketCreate(kCFAllocatorDefault,PF_INET,SOCK_STREAM,IPPROTO_TCP, kCFSocketAcceptCallBack, socketCallBack, &socketCtxt);
    
    
    // Configure the listening socket settings
    struct sockaddr_in sin;
    memset(&sin, 0, sizeof(sin));
    sin.sin_len = sizeof(sin);
    sin.sin_family = AF_INET;           // We are using IPv4
    sin.sin_port = 0;                   // Port 0 instructs the OS to automatically give us a port
    sin.sin_addr.s_addr= INADDR_ANY;    // Any address will do
    
    // Put this information into a data reference
    CFDataRef sincfd = CFDataCreate(
                                    kCFAllocatorDefault,
                                    (UInt8 *)&sin,
                                    sizeof(sin));
    
    // Give the listening socket these options
    CFSocketSetAddress(socketRef, sincfd);
    
    // Get the auto-assigned port from the OS. We need this so Bonjour knows what port to broadcast on
    NSData *socketAddressActualData = CFBridgingRelease(CFSocketCopyAddress(socketRef));
    struct sockaddr_in socketAddressActual;
    memcpy(&socketAddressActual, [socketAddressActualData bytes],
           [socketAddressActualData length]);
    port = ntohs(socketAddressActual.sin_port);
    
    // Connect the listening socket to the run loop. We are now listening for connections.
    CFRunLoopRef currentRunLoop = CFRunLoopGetCurrent();
    CFRunLoopSourceRef runLoopSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, socketRef, 0);
    CFRunLoopAddSource(currentRunLoop, runLoopSource, kCFRunLoopCommonModes);
}

// Broadcasts the listening socket on Bonjour
- (void) broadcastEvent {
    NSLog(@"GQ Broadcasting event");
    // Create a new Bonjour service
 	self.eventService = [[NSNetService alloc] initWithDomain:@"" type:@"_groupq._tcp." name:[NSString stringWithFormat:@"%@\n%@", self.eventName, self.eventPassword] port:port];
    
    // We will be this service's delegate.
	self.eventService.delegate = self;
    
    // Add service to current run loop
	[self.eventService scheduleInRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSRunLoopCommonModes];
    
    // Broadcast the service on Bonjour
	[self.eventService publish];
    NSLog(@"GQ Event created.");
    [self.delegate eventCreated];
}

// Ends the event
- (void) endEvent {
    NSLog(@"GQ Ending event.");
    // Stop broadcasting on Bonjour
    [self.eventService stop];
    [self.eventService removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    // Close our listening socket
    CFSocketInvalidate(socketRef);
    
    // Disconnect users
    for (GroupQConnection* connection in self.userConnections) {
        // Close connections
        [connection disconnectStreams:TRUE];
    }
    
    // Remove users from list
    [self.userConnections removeAllObjects];
    [[GroupQClient sharedClient] startSearchingForEvents];
}


#pragma mark - Connection management

// The socket callback function will be called whenever a new socket connects to the listening socket
void socketCallBack(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info) {
    NSLog(@"GQ Found new socket.");
    // Get the event of the listening socket. This is a class method, so we otherwise have no reference to it.
    GroupQEvent *server = (__bridge GroupQEvent*)info;
    
    // for an AcceptCallBack, the data parameter is a pointer to a CFSocketNativeHandle
    CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle*)data;
    
    [server handleNewNativeSocket:nativeSocketHandle];
}

- (void)handleNewNativeSocket:(CFSocketNativeHandle)nativeSocketHandle {
    GroupQConnection* connection = [[GroupQConnection alloc] init];
    connection.delegate = self;
    [connection connectWithSocketHandle:nativeSocketHandle];
}

- (void) connectionDidConnect:(GroupQConnection *)connection {
    NSLog(@"GQ Connected to user.");
    [self.userConnections addObject:connection];
    [self tellClientsAboutSpotifyStatus];
    [self sendItemsAndQueueTo: connection];
}

- (void) connectionDidNotConnect:(GroupQConnection *)connection {
    NSLog(@"GQ Connection failed.");
}

- (void) connectionDisconnected:(GroupQConnection *)connection {
    NSLog(@"GQ User disconnected");
    [self.userConnections removeObject:connection];
}



#pragma mark - Information transfer and management

- (void) broadcastMessage:(NSString *)message withHeader:(NSString *)header {
    NSLog(@"GQ Broadcasting message to %d clients.", self.userConnections.count);
    for (GroupQConnection* connection in [[GroupQEvent sharedEvent] userConnections]) {
        [connection sendMessage:message withHeader:header];
    }
}

- (void) broadcastObject:(id)object withHeader:(NSString *)header {
    NSLog(@"GQ Broadcasting object to %d clients.", self.userConnections.count);
    for (GroupQConnection* connection in [[GroupQEvent sharedEvent] userConnections]) {
        [connection sendObject:object withHeader:header];
    }
}

- (void) connection:(GroupQConnection *)connection receivedMessage:(NSString *)message withHeader:(NSString *)header {
    NSLog(@"GQ Received message with header %@", header);
    if([header isEqualToString:@"moveSong"]) {
        NSArray *indexes = [message componentsSeparatedByString:@"-"];
        NSString* posSt = (NSString*) [indexes objectAtIndex:0];
        NSString* destSt = (NSString*) [indexes objectAtIndex:1];
        int pos = [posSt integerValue];
        int dest = [destSt integerValue];
        [self.songQueue moveSong:pos to:dest];
        [self tellClientsToMoveSongFrom:pos to:dest];
    }
    else if([header isEqualToString:@"deleteSong"]) {
        int pos = [message integerValue];
        [self.songQueue deleteSong:pos];
        [self tellClientsToDeleteSong:pos];
    }
    else if([header isEqualToString:@"playSong"]) {
        int pos = [message integerValue];
        [self.songQueue playSong:pos];
        pauseTime = 0;
        [self playNextSongInQueue];
        [self tellClientsToPlaySong:pos];
        [self tellClientsPlaybackDetails];
    }
    else if([header isEqualToString:@"resumeSong"]) {
        if(self.songQueue.nowPlaying == nil)
            return;
        isSongPlaying = true;
        if ([self.songQueue.nowPlaying isKindOfClass:[iOSQueueItem class]]) {
            [self.musicPlayer play];
        }
        else {
            [self playNextSongInQueue];
        }
        [self tellClientsPlaybackDetails];
    }
    else if([header isEqualToString:@"pauseSong"]) {
        if(self.songQueue.nowPlaying == nil)
            return;
        isSongPlaying = false;
        if ([self.songQueue.nowPlaying isKindOfClass:[iOSQueueItem class]]) {
            [self.musicPlayer pause];
        }
        else {
            pauseTime = [SpotifyPlayer sharedPlayer].trackPosition;
            [SpotifyPlayer sharedPlayer].isPlaying = NO;
        }
        [self tellClientsPlaybackDetails];
    }
    else if([header isEqualToString:@"requestPlaybackDetail"]) {
        [self tellClientsPlaybackDetails];
    }
}

- (void) connection:(GroupQConnection *)connection receivedObject:(NSData *)message withHeader:(NSString *)header {
    NSLog(@"GQ received object with header %@", header);
    if ([header isEqualToString:@"addSongs"]) {
        NSArray *songs = [NSKeyedUnarchiver unarchiveObjectWithData:message];
        [self.songQueue addSongs:songs];
        [self tellClientsToAddSongs:songs];
    }
    else if([header isEqualToString:@"addSpotifySong"]) {
        SpotifyQueueItem *song = [NSKeyedUnarchiver unarchiveObjectWithData:message];
        [self.songQueue addSpotifySong:song];
        [self tellClientsToAddSpotifySong:song];
    }
    else if([header isEqualToString:@"setVolume"]) {
        NSNumber *volumeLevel = [NSKeyedUnarchiver unarchiveObjectWithData:message];
        [self.musicPlayer setVolume:[volumeLevel floatValue]];
        [SpotifyPlayer sharedPlayer].volume = [volumeLevel doubleValue];
        [self tellClientsPlaybackDetails];
    }
}

#pragma mark - Accessors

- (void) setSpotify:(bool)doesHaveSpotify {
    hasSpotify = doesHaveSpotify;
}

- (bool) hasSpotify {
    return hasSpotify;
}

#pragma mark - Music player methods
- (void) setupMusicPlayer {
    NSLog(@"GQ Setting up music player");
    // Initialize properties
    self.songQueue = [[GroupQQueue alloc] init];
    self.musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    pauseTime = 0;
    // Configure media player notifications so we know when to update the queue
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_ItemChanged:)
                               name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object: self.musicPlayer];
    
    [self.musicPlayer beginGeneratingPlaybackNotifications];
    
    self.library = [[GroupQMusicCollection alloc] initWithSongs:[MPMediaQuery songsQuery] artists:[MPMediaQuery artistsQuery] albums:[MPMediaQuery albumsQuery] playlists:[MPMediaQuery playlistsQuery]];
    
    [[SpotifyPlayer sharedPlayer] setPlayerDelegate:self];
    NSLog(@"GQ Music player set up.");
}

- (void) handle_ItemChanged: (id) notification {
    NSLog(@"GQ Playback state changed.");
    NSLog(@"GQ Playback stopped.");
    if ([self.musicPlayer nowPlayingItem] != self.nowPlayingHandle) {
        [self songDidStopPlaying];
    }
}

- (void) songDidStopPlaying {
    NSLog(@"GQ Song stopped playing");
    pauseTime = 0;
    self.songQueue.nowPlaying = nil;
    [self.songQueue playSong:0];
    [self tellClientsToPlaySong:0];
    [self tellClientsPlaybackDetails];
    [self playNextSongInQueue];
}

- (void) songDidStartPlaying {
    [self tellClientsPlaybackDetails];
}
- (void) playNextSongInQueue {
    NSLog(@"GQ Play next song in queue");
    if (self.songQueue.nowPlaying == nil)
        return;
    if ([self.songQueue.nowPlaying isKindOfClass:[iOSQueueItem class]]) {
        MPMediaItem *song;
        MPMediaPropertyPredicate *predicate;
        MPMediaQuery *songQuery;
        
        predicate = [MPMediaPropertyPredicate predicateWithValue: ((iOSQueueItem*)self.songQueue.nowPlaying).persistentID forProperty:MPMediaItemPropertyPersistentID];
        songQuery = [[MPMediaQuery alloc] init];
        [songQuery addFilterPredicate: predicate];
        if (songQuery.items.count > 0)
        {
            //song exists
            song = [songQuery.items objectAtIndex:0];
            self.nowPlayingHandle = song;
            NSArray *temp = [NSArray arrayWithObject:song];
            [self.musicPlayer setRepeatMode:MPMusicRepeatModeNone];
            [self.musicPlayer setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:temp]];
            [self.musicPlayer setNowPlayingItem: song];
            [self.musicPlayer play];
        }
        else {
            [self songDidStopPlaying];
        }
    }
    else{
        [[SpotifyPlayer sharedPlayer] playTrack:(SpotifyQueueItem*)self.songQueue.nowPlaying atTime: pauseTime];
    }
}

#pragma mark - Sending messages to clients

// Event information
- (void) sendItemsAndQueueTo:(GroupQConnection *)who {
    NSLog(@"GQ Sending items and queue.");
    [who sendObject:self.library withHeader:@"library"];
    [who sendObject:self.songQueue withHeader:@"songQueue"];
}

- (void) tellClientsAboutSpotifyStatus {
    if (hasSpotify) {
        [self broadcastMessage:@"a" withHeader:@"loggedInToSpotify"];
    }
    else {
        [self broadcastMessage:@"a" withHeader:@"loggedOutOfSpotify"];
    }
}

- (void) tellClientsPlaybackDetails {
    GroupQPlaybackDetail *details;
    NSNumber *volume;
    volume = [NSNumber numberWithFloat:self.musicPlayer.volume];
    if(self.songQueue.nowPlaying != nil) {
        NSNumber *currentTime;
        if ([self.songQueue.nowPlaying isKindOfClass:[iOSQueueItem class]]) {
            currentTime = [NSNumber numberWithFloat:self.musicPlayer.currentPlaybackTime];
        }
        else {
            currentTime = [NSNumber numberWithFloat:[SpotifyPlayer sharedPlayer].trackPosition];
        }
        details = [[GroupQPlaybackDetail alloc] initWithSongPlaying: isSongPlaying progress:[currentTime floatValue] volume:[volume floatValue]];
    }
    else {
        details = [[GroupQPlaybackDetail alloc] initWithSongPlaying:false progress:-1 volume:[volume floatValue]];
    }
    NSLog(@"Sending details. Position: %f", details.songProgress);
    [self broadcastObject:details withHeader:@"playbackDetails"];
}

// Queue management
- (void) tellClientsToAddSongs:(MPMediaItemCollection *)songs {
    NSLog(@"GQ telling clients to add song.");
    [self broadcastObject:songs withHeader:@"addSongs"];
}
- (void) tellClientsToAddSpotifySong:(SpotifyQueueItem *)song {
    NSLog(@"GQ telling clients to add spotify song.");
    [self broadcastObject:song withHeader:@"addSpotifySong"];
}
- (void) tellClientsToDeleteSong:(int)position {
    NSLog(@"GQ telling clients to delete song.");
    [self broadcastMessage:[NSString stringWithFormat:@"%d", position] withHeader:@"deleteSong"];
}
- (void) tellClientsToMoveSongFrom:(int)oldPos to:(int)newPos {
    NSLog(@"GQ telling clients to move song.");
    [self broadcastMessage:[NSString stringWithFormat:@"%d-%d", oldPos, newPos] withHeader:@"moveSong"];
}
- (void) tellClientsToPlaySong:(int)position {
    NSLog(@"GQ telling clients to play song.");
    isSongPlaying = true;
    [self broadcastMessage:[NSString stringWithFormat:@"%d", position] withHeader:@"playSong"];
}

#pragma mark - Singleton accessor
+ (GroupQEvent *) sharedEvent {
    static GroupQEvent *sharedEvent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEvent = [[GroupQEvent alloc] init];
    });
    return sharedEvent;
}
@end
