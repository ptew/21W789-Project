//
//  GroupQMusicCollection.m
//  GroupQDemo
//
//  Created by Jono Matthews on 4/8/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "GroupQMusicCollection.h"

@implementation GroupQMusicCollection

- (GroupQMusicCollection *) initWithSongs:(MPMediaQuery*) songs artists: (MPMediaQuery *) artists albums: (MPMediaQuery *) albums playlists: (MPMediaQuery *) playlists; {
    self = [super init];
    self.songCollection = [[NSMutableArray alloc] init];
    self.songSectionNames = [[NSMutableArray alloc] init];
    self.artistCollection = [[NSMutableArray alloc] init];
    self.artistSectionNames = [[NSMutableArray alloc] init];
    self.albumCollection = [[NSMutableArray alloc] init];
    self.albumSectionNames = [[NSMutableArray alloc] init];
    self.playlistCollection = [[NSMutableArray alloc] init];
    self.playlistSectionNames = [[NSMutableArray alloc] init];

    NSArray *sections = [songs itemSections];
    for (MPMediaQuerySection *section in sections) {
        NSMutableArray *sectionToFill = [[NSMutableArray alloc] init];
        for(int i=0; i<section.range.length; i++) {
            MPMediaItem *nextItem = (MPMediaItem*)[songs.items objectAtIndex:i+section.range.location];
            iOSQueueItem *queueItem = [[iOSQueueItem alloc] init];
            queueItem.title = [nextItem valueForProperty:MPMediaItemPropertyTitle];
            queueItem.artist = [nextItem valueForProperty:MPMediaItemPropertyArtist];
            queueItem.album = [nextItem valueForProperty:MPMediaItemPropertyAlbumTitle];
            queueItem.playbackDuration = [nextItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
            queueItem.persistentID = [nextItem valueForProperty:MPMediaItemPropertyPersistentID];
            [sectionToFill addObject:queueItem];
        }
        [self.songSectionNames addObject:section.title];
        [self.songCollection addObject:sectionToFill];
    }
    
    sections = [artists itemSections];
    for (MPMediaQuerySection *section in sections) {
        NSMutableArray *sectionToFill = [[NSMutableArray alloc] init];
        for(int i=0; i<section.range.length; i++) {
            MPMediaItem *nextItem = (MPMediaItem*)[artists.items objectAtIndex:i+section.range.location];
            iOSQueueItem *queueItem = [[iOSQueueItem alloc] init];
            queueItem.title = [nextItem valueForProperty:MPMediaItemPropertyTitle];
            queueItem.artist = [nextItem valueForProperty:MPMediaItemPropertyArtist];
            queueItem.album = [nextItem valueForProperty:MPMediaItemPropertyAlbumTitle];
            queueItem.playbackDuration = [nextItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
            queueItem.persistentID = [nextItem valueForProperty:MPMediaItemPropertyPersistentID];
            [sectionToFill addObject:queueItem];
        }
        [self.artistSectionNames addObject:section.title];
        [self.artistCollection addObject:sectionToFill];
    }
    
    sections = [playlists itemSections];
    for (MPMediaQuerySection *section in sections) {
        NSMutableArray *sectionToFill = [[NSMutableArray alloc] init];
        for(int i=0; i<section.range.length; i++) {
            MPMediaItem *nextItem = (MPMediaItem*)[playlists.items objectAtIndex:i+section.range.location];
            iOSQueueItem *queueItem = [[iOSQueueItem alloc] init];
            queueItem.title = [nextItem valueForProperty:MPMediaItemPropertyTitle];
            queueItem.artist = [nextItem valueForProperty:MPMediaItemPropertyArtist];
            queueItem.album = [nextItem valueForProperty:MPMediaItemPropertyAlbumTitle];
            queueItem.playbackDuration = [nextItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
            queueItem.persistentID = [nextItem valueForProperty:MPMediaItemPropertyPersistentID];
            [sectionToFill addObject:queueItem];
        }
        [self.playlistSectionNames addObject:section.title];
        [self.playlistCollection addObject:sectionToFill];
    }
    
    sections = [albums itemSections];
    for (MPMediaQuerySection *section in sections) {
        NSMutableArray *sectionToFill = [[NSMutableArray alloc] init];
        for(int i=0; i<section.range.length; i++) {
            MPMediaItem *nextItem = (MPMediaItem*)[albums.items objectAtIndex:i+section.range.location];
            iOSQueueItem *queueItem = [[iOSQueueItem alloc] init];
            queueItem.title = [nextItem valueForProperty:MPMediaItemPropertyTitle];
            queueItem.artist = [nextItem valueForProperty:MPMediaItemPropertyArtist];
            queueItem.album = [nextItem valueForProperty:MPMediaItemPropertyAlbumTitle];
            queueItem.playbackDuration = [nextItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
            queueItem.persistentID = [nextItem valueForProperty:MPMediaItemPropertyPersistentID];
            [sectionToFill addObject:queueItem];
        }
        [self.albumSectionNames addObject:section.title];
        [self.albumCollection addObject:sectionToFill];
    }
    return self;
}


- (void) encodeWithCoder:(NSCoder *)aCoder {
    NSLog(@"Song collection has %d items.", self.songCollection.count);
    NSLog(@"First section is %@", [self.songCollection objectAtIndex:0]);
    [aCoder encodeObject:self.songCollection forKey:@"songs"];
    [aCoder encodeObject:self.artistCollection forKey:@"artists"];
    [aCoder encodeObject:self.albumCollection forKey:@"albums"];
    [aCoder encodeObject:self.playlistCollection forKey:@"playlists"];
    [aCoder encodeObject:self.songSectionNames forKey:@"namesongs"];
    [aCoder encodeObject:self.artistSectionNames forKey:@"nameartists"];
    [aCoder encodeObject:self.albumSectionNames forKey:@"namealbums"];
    [aCoder encodeObject:self.playlistSectionNames forKey:@"nameplaylists"];
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    NSLog(@"Starting decoding");
    self.songCollection = [aDecoder decodeObjectForKey:@"songs"];
    self.artistCollection = [aDecoder decodeObjectForKey:@"artists"];
    self.albumCollection = [aDecoder decodeObjectForKey:@"albums"];
    self.playlistCollection = [aDecoder decodeObjectForKey:@"playlists"];
    self.songSectionNames = [aDecoder decodeObjectForKey:@"namesongs"];
    self.artistSectionNames = [aDecoder decodeObjectForKey:@"nameartists"];
    self.albumSectionNames = [aDecoder decodeObjectForKey:@"namealbums"];
    self.playlistSectionNames = [aDecoder decodeObjectForKey:@"nameplaylists"];
    NSLog(@"Finished decoding");
    return self;
}
@end
