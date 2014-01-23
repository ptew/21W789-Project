//
//  GroupQPlaybackDetail.h
//  GroupQDemo
//
//  Created by Jono Matthews on 4/8/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupQPlaybackDetail : NSObject <NSCoding> {
    bool isSongPlaying;
    float songProgress;
    float songVolume;
}

- (GroupQPlaybackDetail*) initWithSongPlaying:(bool) playing progress: (float) progress volume: (float) volume;

- (bool) isSongPlaying;
- (float) songProgress;
- (float) songVolume;

@end
