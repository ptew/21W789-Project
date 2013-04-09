//
//  SpotifyPlayerDelegate.h
//  GroupQDemo
//
//  Created by Bradley Gross on 4/7/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>

//This delegate is called by the spotify player whenever the current song stops playing.
@protocol SpotifyPlayerDelegate <NSObject>
- (void) songDidStopPlaying;
- (void) songDidStartPlaying;
@end
