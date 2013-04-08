//
//  AddPlaylistViewController.m
//  GroupQDemo
//
//  Created by Parker Allen Tew on 4/7/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "AddPlaylistViewController.h"

@interface AddPlaylistViewController ()
@property (nonatomic,weak) NSString *type;
@end

@implementation AddPlaylistViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setEditing:TRUE animated:TRUE];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[GroupQClient sharedClient].ipodPlaylists collections].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    MPMediaPlaylist *playlist = [[[GroupQClient sharedClient].ipodPlaylists collections] objectAtIndex:indexPath.row];
    cell.textLabel.text = [playlist valueForProperty:MPMediaPlaylistPropertyName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        MPMediaPlaylist *playlist = [[[GroupQClient sharedClient].ipodPlaylists collections] objectAtIndex:indexPath.row];
        //handle insert...
        for (MPMediaItem *song in playlist.items) {
            [[GroupQClient sharedClient].pickerSongs addObject:song];
        }
    }
}

- (IBAction)donePressed:(UIBarButtonItem *)sender {
    [[GroupQClient sharedClient].queue addSongs:[MPMediaItemCollection collectionWithItems:[GroupQClient sharedClient].pickerSongs]];
    [GroupQClient sharedClient].pickerSongs = nil;
    [self performSegueWithIdentifier:@"doneWithPicker" sender:self];
    
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    [GroupQClient sharedClient].pickerSongs = nil;
    [self performSegueWithIdentifier:@"doneWithPicker" sender:self];
}
@end
