//
//  GroupQClient.m
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/4/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "GroupQClient.h"

@interface GroupQClient ()
- (void) tellServerIfDJ;

@property (strong, nonatomic) NSNetServiceBrowser *browser;         // The Bonjour service browser
@property (strong, nonatomic) NSMutableArray *events;               // A list of all current events
@property (strong, nonatomic) GroupQConnection *connectionToServer; // The connection to the server
@end


@implementation GroupQClient

- (GroupQClient *) init {
    self = [super init];
    
    // Set up the Bonjour browser
    self.browser = [[NSNetServiceBrowser alloc] init];
    self.browser.delegate = self;
    
    // Initialize our list of events
    self.events = [[NSMutableArray alloc] init];
    
    self.queue = [[GroupQQueue alloc] init];
    
    isSongPlaying = false;
    hostHasSpotify = false;
    songVolume = 0;
    songProgress = 0;
    
    self.pickerSongs = [[NSMutableArray alloc] init];
    [self setHost:false];
    return self;
}


- (void) startSearchingForEvents {
    // Start the Bonjour browser search
    self.events = [[NSMutableArray alloc] init];
    [self.delegate eventsUpdated];
    [self.browser searchForServicesOfType:@"_groupq._tcp." inDomain:@""];
}

- (void) stopSearching {
    // Stop the Bonjour browser search
    [self.browser stop];
}

- (void) connectToEvent:(NSNetService *)whichEvent {
    // Create a connection and attempt to connect to the service.
    self.connectionToServer = [[GroupQConnection alloc] init];
    self.connectionToServer.delegate = self;
    [self.connectionToServer connectWithService:whichEvent];
}

- (void) disconnect {
    [self.connectionToServer disconnectStreams:YES];
}


- (NSArray *) getEvents {
    return [NSArray arrayWithArray:self.events];
}


- (void) sendMessage:(NSString *)text withHeader:(NSString *)header {
    [self.connectionToServer sendMessage:text withHeader:header];
}

- (void) sendObject:(id)object withHeader:(NSString *)header {
    [self.connectionToServer sendObject:object withHeader:header];
}

#pragma mark GroupQConnection methods

- (void) connectionDisconnected:(GroupQConnection *)connection {
    [self.delegate disconnectedFromEvent];
}

- (void) connectionDidConnect:(GroupQConnection *)connection {
}

- (void) connectionDidNotConnect:(GroupQConnection *)connection {
    [self.delegate didNotConnectToEvent];
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [self.events addObject:aNetService];
    if (!moreComing)
        [self.delegate eventsUpdated];
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [self.events removeObject:aNetService];
    if (!moreComing)
        [self.delegate eventsUpdated];
}

- (void) connection:(GroupQConnection *)connection receivedMessage:(NSString *)message withHeader:(NSString *)header {
    NSLog(@"Received message: %@ with header: %@", message, header);
    if([header isEqualToString:@"deleteSong"]){
        [self.queue deleteSong:[message integerValue]];
    }
    else if([header isEqualToString:@"moveSong"]){
        NSArray *components = [message componentsSeparatedByString:@"-"];
        [self.queue moveSong:[components[0] integerValue] to:[components[1] integerValue]];
    }
    else if([header isEqualToString:@"playSong"]){
        [self.queue playSong:[message integerValue]];
    }
    else if([header isEqualToString:@"pauseSong"]) {
        isSongPlaying = false;
    }
    else if([header isEqualToString:@"resumeSong"]) {
        isSongPlaying = true;
    }
    else if([header isEqualToString:@"loggedInToSpotify"]) {
        hostHasSpotify = true;
    }
    else if([header isEqualToString:@"loggedOutOfSpotify"]) {
        hostHasSpotify = false;
    }
    else{
        NSLog(@"Unrecognized header: %@ parsed in recievedMessages.", header);
    }

}

- (void) connection:(GroupQConnection *)connection receivedObject:(NSData *)message withHeader:(NSString *)header {
    NSLog(@"Received object with header: %@", header);
    if([header isEqualToString:@"library"]){
        self.library = [NSKeyedUnarchiver unarchiveObjectWithData:message];
    }
    else if([header isEqualToString:@"songQueue"]){
        self.queue = [NSKeyedUnarchiver unarchiveObjectWithData:message];
        [self.delegate didConnectToEvent];
    }
    else if([header isEqualToString:@"addSongs"]){
        [self.queue addSongs:[NSKeyedUnarchiver unarchiveObjectWithData:message]];
    }
    else if([header isEqualToString:@"addSpotifySong"]){
        [self.queue addSpotifySong:[NSKeyedUnarchiver unarchiveObjectWithData:message]];
    }
    else if([header isEqualToString:@"setVolume"]) {
        NSNumber *volume = [NSKeyedUnarchiver unarchiveObjectWithData:message];
        songVolume = [volume floatValue];
    }
    else if([header isEqualToString:@"currentPlaybackTime"]) {
        NSNumber *time = [NSKeyedUnarchiver unarchiveObjectWithData:message];
        songProgress = [time floatValue];
    }
    else{
        NSLog(@"Unrecognized header: %@ parsed in recievedObjects.", header);
    }       
}
//end GroupQConnection methods

- (bool) isDJ {
    return isDJ;
}

- (void) setDJ:(bool)dj {
    isDJ = dj;
}

+ (GroupQClient *) sharedClient {
    static GroupQClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[GroupQClient alloc] init];
    });
    return sharedClient;
}

- (void) tellServerIfDJ{
    if (isDJ) {
        [self.connectionToServer sendMessage:@"dj" withHeader:@"registerUser"];
    }
    else {
        [self.connectionToServer sendMessage:@"listener" withHeader:@"registerUser"];
    }
}

- (void) tellServerToAddSongs:(NSArray *)songs {
    [self.connectionToServer sendObject:songs withHeader:@"addSongs"];
}
- (void) tellServerToMoveSongFrom:(int)index To:(int)newIndex {
    [self.connectionToServer sendMessage:[NSString stringWithFormat:@"%d-%d", index, newIndex] withHeader:@"moveSong"];
}
- (void) tellServerToDeleteSong:(int)index {
    [self.connectionToServer sendMessage:[NSString stringWithFormat:@"%d", index] withHeader:@"moveSong"];
}
- (void) tellServerToPlaySong:(int)index{
    [self.connectionToServer sendMessage:[NSString stringWithFormat:@"%d", index] withHeader:@"playSong"];
}
- (void) tellServerToaddSpotifySong:(SpotifyQueueItem *)song{
    [self.connectionToServer sendObject:song withHeader:@"addSpotifySong"];
}

- (void) tellServerToResumeSong{
    [self.connectionToServer sendMessage:@"" withHeader:@"resumeSong"];
}
- (void) tellServerToPauseSong{
    [self.connectionToServer sendMessage:@"" withHeader:@"pauseSong"];
}
- (void) tellServerToSetVolume: (NSNumber *) level {
    [self.connectionToServer sendObject:level withHeader:@"setVolume"];
}
- (void) tellServerToSendPlaybackDetail {
    [self.connectionToServer sendMessage:@"" withHeader:@"requestPlaybackDetail"];
}

- (bool) isHost {
    return isHost;
}

- (bool)isSongPlaying {
    return isSongPlaying;
}

- (bool) hostHasSpotify {
    return hostHasSpotify;
}

- (float) songVolume {
    return songVolume;
}

- (float) songProgress {
    return songProgress;
}

- (void) setHost:(bool)isTheHost {
    isHost = isTheHost;
}

- (void) connectAsHost {
    [self setHost:true];
    
}
@end
