//
//  GroupQPlaybackDetail.m
//  GroupQDemo
//
//  Created by Jono Matthews on 4/8/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "GroupQPlaybackDetail.h"

@implementation GroupQPlaybackDetail
- (GroupQPlaybackDetail*) initWithSongPlaying:(bool)playing progress:(float)progress volume:(float)volume {
    self = [super init];
    isSongPlaying = playing;
    songProgress = progress;
    songVolume = volume;
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:isSongPlaying forKey:@"isPlaying"];
    [aCoder encodeFloat:songProgress forKey:@"progress"];
    [aCoder encodeFloat:songVolume forKey:@"volume"];
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    isSongPlaying = [aDecoder decodeBoolForKey:@"isPlaying"];
    songProgress = [aDecoder decodeFloatForKey:@"progress"];
    songVolume = [aDecoder decodeFloatForKey:@"volume"];
    return self;
}

- (bool)    isSongPlaying   {return isSongPlaying;}
- (float)   songVolume      {return songVolume;}
- (float)   songProgress    {return songProgress;}

@end
