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
    
    // Initialize containers
    self.songCollection = [[NSMutableArray alloc] init];
    self.songSectionNames = [[NSMutableArray alloc] init];
    self.artistCollection = [[NSMutableArray alloc] init];
    self.artistSectionNames = [[NSMutableArray alloc] init];
    self.albumCollection = [[NSMutableArray alloc] init];
    self.albumSectionNames = [[NSMutableArray alloc] init];
    self.playlistCollection = [[NSMutableDictionary alloc] init];

    // Load songs
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
    
    // Load artists
    sections = [artists itemSections];
    for (MPMediaQuerySection *section in sections) {
        NSMutableDictionary *sectionToFill = [[NSMutableDictionary alloc] init];
        for(int i=0; i<section.range.length; i++) {
            MPMediaItem *nextItem = (MPMediaItem*)[artists.items objectAtIndex:i+section.range.location];
            iOSQueueItem *queueItem = [[iOSQueueItem alloc] init];
            queueItem.title = [nextItem valueForProperty:MPMediaItemPropertyTitle];
            queueItem.artist = [nextItem valueForProperty:MPMediaItemPropertyArtist];
            queueItem.album = [nextItem valueForProperty:MPMediaItemPropertyAlbumTitle];
            queueItem.playbackDuration = [nextItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
            queueItem.persistentID = [nextItem valueForProperty:MPMediaItemPropertyPersistentID];
            if (queueItem.artist != nil) {
                if([sectionToFill objectForKey:queueItem.artist]==nil){
                    NSMutableArray *artistArray = [NSMutableArray arrayWithObject:queueItem];
                    [sectionToFill setObject:artistArray forKey:queueItem.artist];
                }
                else{
                    [((NSMutableArray *)[sectionToFill objectForKey:queueItem.artist]) addObject:queueItem];
                }
            }
        }
        [self.artistSectionNames addObject:section.title];
        [self.artistCollection addObject:sectionToFill];
    }
    
    // Load playlists
    NSArray *playlistObjects = [playlists collections];
    for (MPMediaPlaylist *playlist in playlistObjects) {
        NSMutableArray *playlistToFill = [[NSMutableArray alloc] init];
        NSArray *songs = [playlist items];
        for(MPMediaItem *nextItem in songs) {
            iOSQueueItem *queueItem = [[iOSQueueItem alloc] init];
            queueItem.title = [nextItem valueForProperty:MPMediaItemPropertyTitle];
            queueItem.artist = [nextItem valueForProperty:MPMediaItemPropertyArtist];
            queueItem.album = [nextItem valueForProperty:MPMediaItemPropertyAlbumTitle];
            queueItem.playbackDuration = [nextItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
            queueItem.persistentID = [nextItem valueForProperty:MPMediaItemPropertyPersistentID];
            [playlistToFill addObject:queueItem];
        }
        [self.playlistCollection setObject:playlistToFill forKey:[playlist valueForProperty:MPMediaPlaylistPropertyName]];
    }
    
    // Load albums
    sections = [albums itemSections];
    for (MPMediaQuerySection *section in sections) {
        NSMutableDictionary *sectionToFill = [[NSMutableDictionary alloc] init];
        for(int i=0; i<section.range.length; i++) {
            MPMediaItem *nextItem = (MPMediaItem*)[albums.items objectAtIndex:i+section.range.location];
            iOSQueueItem *queueItem = [[iOSQueueItem alloc] init];
            queueItem.title = [nextItem valueForProperty:MPMediaItemPropertyTitle];
            queueItem.artist = [nextItem valueForProperty:MPMediaItemPropertyArtist];
            queueItem.album = [nextItem valueForProperty:MPMediaItemPropertyAlbumTitle];
            queueItem.playbackDuration = [nextItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
            queueItem.persistentID = [nextItem valueForProperty:MPMediaItemPropertyPersistentID];
            if (queueItem.album != nil) {
                if([sectionToFill objectForKey:queueItem.album]==nil){
                    NSMutableArray *artistArray = [NSMutableArray arrayWithObject:queueItem];
                    [sectionToFill setObject:artistArray forKey:queueItem.album];
                }
                else{
                    [((NSMutableArray *)[sectionToFill objectForKey:queueItem.album]) addObject:queueItem];
                }
            }
        }
        [self.albumSectionNames addObject:section.title];
        [self.albumCollection addObject:sectionToFill];
    }
    return self;
}


- (void) encodeWithCoder:(NSCoder *)aCoder {
    // Encodes the library for stream transport
    [aCoder encodeObject:self.songCollection forKey:@"songs"];
    [aCoder encodeObject:self.artistCollection forKey:@"artists"];
    [aCoder encodeObject:self.albumCollection forKey:@"albums"];
    [aCoder encodeObject:self.playlistCollection forKey:@"playlists"];
    [aCoder encodeObject:self.songSectionNames forKey:@"namesongs"];
    [aCoder encodeObject:self.artistSectionNames forKey:@"nameartists"];
    [aCoder encodeObject:self.albumSectionNames forKey:@"namealbums"];
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    // Decodes data from a stream into a library
    self.songCollection = [aDecoder decodeObjectForKey:@"songs"];
    self.artistCollection = [aDecoder decodeObjectForKey:@"artists"];
    self.albumCollection = [aDecoder decodeObjectForKey:@"albums"];
    self.playlistCollection = [aDecoder decodeObjectForKey:@"playlists"];
    self.songSectionNames = [aDecoder decodeObjectForKey:@"namesongs"];
    self.artistSectionNames = [aDecoder decodeObjectForKey:@"nameartists"];
    self.albumSectionNames = [aDecoder decodeObjectForKey:@"namealbums"];
    return self;
}
@end
