//
//  GroupQClient.m
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/4/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "GroupQClient.h"

@interface GroupQClient ()
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

// Delegate functions
- (void) connectionDisconnected:(GroupQConnection *)connection {
    [self.delegate disconnectedFromEvent];
}

- (void) connectionDidConnect:(GroupQConnection *)connection {
    [self.delegate didConnectToEvent];
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
    [self.delegate receivedMessage:message withHeader:header];
}

- (void) connection:(GroupQConnection *)connection receivedObject:(NSData *)message withHeader:(NSString *)header {
    [self.delegate receivedObject:message withHeader:header];
}

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

@end
