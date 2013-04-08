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
    
    NSMutableArray *arrayToFill = [[NSMutableArray alloc] init];
    NSMutableArray *sectionNames = [[NSMutableArray alloc] init];
    NSArray *sections = [songs itemSections];
    for (MPMediaQuerySection *section in sections) {
        NSMutableArray *sectionToFill = [[NSMutableArray alloc] init];
        for(int i=0; i<section.range.length; i++) {
            [sectionToFill addObject:[songs.items objectAtIndex:i+section.range.location]];
        }
        [sectionNames addObject:section.title];
        [arrayToFill addObject:sectionToFill];
    }
    self.songSectionNames = [NSArray arrayWithArray:sectionNames];
    self.songCollection = [NSArray arrayWithArray:arrayToFill];
    
    arrayToFill = [[NSMutableArray alloc] init];
    sectionNames = [[NSMutableArray alloc] init];
    sections = [artists itemSections];
    for (MPMediaQuerySection *section in sections) {
        NSMutableArray *sectionToFill = [[NSMutableArray alloc] init];
        for(int i=0; i<section.range.length; i++) {
            [sectionToFill addObject:[artists.items objectAtIndex:i+section.range.location]];
        }
        [sectionNames addObject:section.title];
        [arrayToFill addObject:sectionToFill];
    }
    self.artistSectionNames = [NSArray arrayWithArray:sectionNames];
    self.artistCollection = [NSArray arrayWithArray:arrayToFill];
    
    
    arrayToFill = [[NSMutableArray alloc] init];
    sectionNames = [[NSMutableArray alloc] init];
    sections = [playlists itemSections];
    for (MPMediaQuerySection *section in sections) {
        NSMutableArray *sectionToFill = [[NSMutableArray alloc] init];
        for(int i=0; i<section.range.length; i++) {
            [sectionToFill addObject:[playlists.items objectAtIndex:i+section.range.location]];
        }
        [sectionNames addObject:section.title];
        [arrayToFill addObject:sectionToFill];
    }
    self.playlistSectionNames = [NSArray arrayWithArray:sectionNames];
    self.playlistCollection = [NSArray arrayWithArray:arrayToFill];
    
    arrayToFill = [[NSMutableArray alloc] init];
    sectionNames = [[NSMutableArray alloc] init];
    sections = [albums itemSections];
    for (MPMediaQuerySection *section in sections) {
        NSMutableArray *sectionToFill = [[NSMutableArray alloc] init];
        for(int i=0; i<section.range.length; i++) {
            [sectionToFill addObject:[albums.items objectAtIndex:i+section.range.location]];
        }
        [sectionNames addObject:section.title];
        [arrayToFill addObject:sectionToFill];
    }
    self.albumSectionNames = [NSArray arrayWithArray:sectionNames];
    self.albumCollection = [NSArray arrayWithArray:arrayToFill];
    return self;
}


- (void) encodeWithCoder:(NSCoder *)aCoder {
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
    self.songCollection = [aDecoder decodeObjectForKey:@"songs"];
    self.artistCollection = [aDecoder decodeObjectForKey:@"artists"];
    self.albumCollection = [aDecoder decodeObjectForKey:@"albums"];
    self.playlistCollection = [aDecoder decodeObjectForKey:@"playlists"];
    self.songSectionNames = [aDecoder decodeObjectForKey:@"namesongs"];
    self.artistSectionNames = [aDecoder decodeObjectForKey:@"nameartists"];
    self.albumSectionNames = [aDecoder decodeObjectForKey:@"namealbums"];
    self.playlistSectionNames = [aDecoder decodeObjectForKey:@"nameplaylists"];
    return self;
}
@end
