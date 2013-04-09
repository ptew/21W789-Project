//
//  GroupQClientDelegate.h
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/4/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GroupQClientDelegate<NSObject>

// Sent whenever the list of events was updates
- (void) eventsUpdated;

// Sent when a connection to an event was made
- (void) didConnectToEvent;
// Sent when a connection to an event failed
- (void) didNotConnectToEvent;
// Sent when the connection was terminated
- (void) disconnectedFromEvent;

// Send when the event's information is received
- (void) initialInformationReceived;
// Sent when new playback details are available
- (void) playbackDetailsReceived;
// Sent when new information about a Spotify connection is available
- (void) spotifyInfoReceived;

@end
