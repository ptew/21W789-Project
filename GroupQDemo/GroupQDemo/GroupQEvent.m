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




// Private function to handle new connections
- (void)handleNewNativeSocket:(CFSocketNativeHandle)nativeSocketHandle;
@end


@implementation GroupQEvent

- (void) createEventWithName: (NSString*) name andPassword: (NSString*) password {
    // Store the event name and set up the user list
    self.eventName = name;
    self.eventPassword = password;
    self.userConnections = [[NSMutableArray alloc] init];
    
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
    // The event was created!
    [self.delegate eventCreated];
}

// Broadcasts the listening socket on Bonjour
- (void) broadcastEvent {
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
    
    // The event ended!
    [self.delegate eventEnded];
}

// The socket callback function will be called whenever a new socket connects to the listening socket
void socketCallBack(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info) {
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
    [self.userConnections addObject:connection];
}

- (void) broadcastMessage:(NSString *)message withHeader:(NSString *)header {
    for (GroupQConnection* connection in [[GroupQEvent sharedEvent] userConnections]) {
        [connection sendMessage:message withHeader:header];
    }
}
#pragma mark Connection Delegate Methods
- (void) connectionDidConnect:(GroupQConnection *)connection {
    [self.delegate userUpdate];
}

- (void) connectionDidNotConnect:(GroupQConnection *)connection {
    [self.userConnections removeObject:connection];
    [self.delegate userUpdate];
}

- (void) connectionDisconnected:(GroupQConnection *)connection {
    [self.userConnections removeObject:connection];
    [self.delegate userUpdate];
}

- (void) connection:(GroupQConnection *)connection receivedMessage:(NSString *)message withHeader:(NSString *)header {
    [self.delegate receivedMessage:message withHeader:header from:connection];
}

- (void) connection:(GroupQConnection *)connection receivedObject:(NSData *)message withHeader:(NSString *)header {
    [self.delegate receivedObject:message withHeader:header from:connection];
}

+ (GroupQEvent *) sharedEvent {
    static GroupQEvent *sharedEvent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEvent = [[GroupQEvent alloc] init];
    });
    return sharedEvent;
}
@end
