//
//  GroupQConnection.h
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/4/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupQConnectionDelegate.h"

@interface GroupQConnection : NSObject <NSStreamDelegate>

// The connection's delegate
@property (strong, nonatomic) id<GroupQConnectionDelegate> delegate;

#pragma mark - Connecting
// Connects to a service
- (void) connectWithService: (NSNetService*) service;
// Connects to a socket handle
- (void) connectWithSocketHandle: (CFSocketNativeHandle) handle;

#pragma mark - Disconnecting
// Disconnects everything
- (void) disconnectStreams: (BOOL) sendDisconnect;

#pragma mark - Information transfer
// Sends text to the other end of the connection
- (void) sendMessage: (NSString*) message withHeader: (NSString*) header;

- (void) sendObject: (id) what withHeader: (NSString*) header;

@end
