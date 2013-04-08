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
}


@property (strong, nonatomic) MPMusicPlayerController *musicPlayer;
@property (strong, nonatomic) GroupQQueue *songQueue;
@property (strong, nonatomic) MPMediaItemCollection *iPodItemCollection;
@property (strong, nonatomic) MPMediaQuery *iPodPlaylistQuery;

// Private function to handle new connections
- (void)handleNewNativeSocket:(CFSocketNativeHandle)nativeSocketHandle;

- (void) setupMusicPlayer;

- (void) playNextSongInQueue;

- (void) sendItemsAndQueueTo: (GroupQConnection *) who;

- (void) tellClientsToAddSongs: (MPMediaItemCollection *) songs;
- (void) tellClientsToMoveSongFrom: (int) oldPos to: (int) newPos;
- (void) tellClientsToDeleteSong: (int) position;
- (void) tellClientsToPlaySong: (int) position;
- (void) tellClientsToAddSpotifySong: (SpotifyQueueItem *) song;
@end


@implementation GroupQEvent

- (void) createEventWithName: (NSString*) name andPassword: (NSString*) password {
    NSLog(@"Creating event.");
    
    // Store the event name and set up the user list
    self.eventName = name;
    self.eventPassword = password;
    self.userConnections = [[NSMutableArray alloc] init];
    
    [self setupMusicPlayer];
    
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
    [self.delegate eventCreated];
}

// Broadcasts the listening socket on Bonjour
- (void) broadcastEvent {
    NSLog(@"Broadcasting event");
    // Create a new Bonjour service
 	self.eventService = [[NSNetService alloc] initWithDomain:@"" type:@"_groupq._tcp." name:[NSString stringWithFormat:@"%@\n%@", self.eventName, self.eventPassword] port:port];
    
    // We will be this service's delegate.
	self.eventService.delegate = self;
    
    // Add service to current run loop
	[self.eventService scheduleInRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSRunLoopCommonModes];
    
    // Broadcast the service on Bonjour
	[self.eventService publish];
}

// Ends the event
- (void) endEvent {
    NSLog(@"Ending event.");
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
}

// The socket callback function will be called whenever a new socket connects to the listening socket
void socketCallBack(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info) {
    NSLog(@"Found new socket.");
    // Get the event of the listening socket. This is a class method, so we otherwise have no reference to it.
    GroupQEvent *server = (__bridge GroupQEvent*)info;
    
    // for an AcceptCallBack, the data parameter is a pointer to a CFSocketNativeHandle
    CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle*)data;
    
    [server handleNewNativeSocket:nativeSocketHandle];
}


// Handle new connections
- (void)handleNewNativeSocket:(CFSocketNativeHandle)nativeSocketHandle {
    GroupQConnection* connection = [[GroupQConnection alloc] init];
    connection.delegate = self;
    [connection connectWithSocketHandle:nativeSocketHandle];
}

- (void) broadcastMessage:(NSString *)message withHeader:(NSString *)header {
    NSLog(@"Broadcasting message to %d clients.", self.userConnections.count);
    for (GroupQConnection* connection in [[GroupQEvent sharedEvent] userConnections]) {
        [connection sendMessage:message withHeader:header];
    }
}

- (void) broadcastObject:(id)object withHeader:(NSString *)header {
    NSLog(@"Broadcasting object to %d clients.", self.userConnections.count);
    for (GroupQConnection* connection in [[GroupQEvent sharedEvent] userConnections]) {
        [connection sendObject:object withHeader:header];
    }
}

#pragma mark Connection Delegate Methods
- (void) connectionDidConnect:(GroupQConnection *)connection {
    NSLog(@"Connected to user.");
    [self.userConnections addObject:connection];
    //[self sendItemsAndQueueTo: connection];
}

- (void) connectionDidNotConnect:(GroupQConnection *)connection {}

- (void) connectionDisconnected:(GroupQConnection *)connection {
    [self.userConnections removeObject:connection];
}

- (void) connection:(GroupQConnection *)connection receivedMessage:(NSString *)message withHeader:(NSString *)header {
    if ([header isEqualToString:@"registerUser"]) {
        if([message isEqualToString:@"dj"]) {
            [connection setDJ:true];
        }
        else {
            [connection setDJ:false];
        }
    }
    else if([header isEqualToString:@"moveSong"]) {
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
        [self playNextSongInQueue];
        [self tellClientsToPlaySong:pos];
    }
}

- (void) connection:(GroupQConnection *)connection receivedObject:(NSData *)message withHeader:(NSString *)header {
    if ([header isEqualToString:@"addSongs"]) {
        MPMediaItemCollection *songs = [NSKeyedUnarchiver unarchiveObjectWithData:message];
        [self.songQueue addSongs:songs];
        [self tellClientsToAddSongs:songs];
    }
    else if([header isEqualToString:@"addSpotifySong"]) {
        SpotifyQueueItem *song = [NSKeyedUnarchiver unarchiveObjectWithData:message];
        [self.songQueue addSpotifySong:song];
        [self tellClientsToAddSpotifySong:song];
    }
}

+ (GroupQEvent *) sharedEvent {
    static GroupQEvent *sharedEvent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEvent = [[GroupQEvent alloc] init];
    });
    return sharedEvent;
}


//**********==================
// MUSIC PLAYER METHODS
//**********==================
- (void) setupMusicPlayer {
    // Initialize properties
    self.songQueue = [[GroupQQueue alloc] init];
    self.musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    // Configure media player notifications so we know when to update the queue
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_PlaybackStateChanged:)
                               name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                             object: self.musicPlayer];
    
    [self.musicPlayer beginGeneratingPlaybackNotifications];
    
    self.iPodItemCollection = [MPMediaItemCollection collectionWithItems:[MPMediaQuery songsQuery].items];
    self.iPodPlaylistQuery = [MPMediaQuery playlistsQuery];
}

- (void) handle_PlaybackStateChanged: (id) notification {
    NSLog(@"Playback state changed.");
    MPMusicPlaybackState playbackState = [self.musicPlayer playbackState];
    if (playbackState == MPMusicPlaybackStateStopped) {
        NSLog(@"Playback stopped.");
        [self songDidStopPlaying];
	}
}

- (void) songDidStopPlaying {
    [self.songQueue playSong:0];
    [self tellClientsToPlaySong:0];
    [self playNextSongInQueue];
}

- (void) playNextSongInQueue {
    if (self.songQueue.nowPlaying == nil)
        return;
    
    if ([self.songQueue.nowPlaying isKindOfClass:[MPMediaItem class]]) {
        [self.musicPlayer setNowPlayingItem: self.songQueue.nowPlaying];
        [self.musicPlayer play];
    }
    else{
        [[SpotifyPlayer sharedPlayer] playTrack:(SpotifyQueueItem*)self.songQueue.nowPlaying];
    }
}

- (void) sendItemsAndQueueTo:(GroupQConnection *)who {
    [self broadcastObject:self.iPodItemCollection withHeader:@"ipodItems"];
    [self broadcastObject:self.iPodPlaylistQuery withHeader:@"ipodPlaylists"];
    [self broadcastObject:self.songQueue withHeader:@"songQueue"];
}

- (void) tellClientsToAddSongs:(MPMediaItemCollection *)songs {
    [self broadcastObject:songs withHeader:@"addSongs"];
}
- (void) tellClientsToAddSpotifySong:(SpotifyQueueItem *)song {
    [self broadcastObject:song withHeader:@"addSpotifySong"];
}
- (void) tellClientsToDeleteSong:(int)position {
    [self broadcastMessage:[NSString stringWithFormat:@"%d", position] withHeader:@"deleteSong"];
}
- (void) tellClientsToMoveSongFrom:(int)oldPos to:(int)newPos {
    [self broadcastMessage:[NSString stringWithFormat:@"%d-%d", oldPos, newPos] withHeader:@"moveSong"];
}
- (void) tellClientsToPlaySong:(int)position {
    [self broadcastMessage:[NSString stringWithFormat:@"%d", position] withHeader:@"playSong"];
}
@end
