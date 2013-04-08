//
//  AddSongViewController.m
//  GroupQDemo
//
//  Created by Parker Allen Tew on 4/7/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "AddSongViewController.h"

@interface AddSongViewController ()
@end

@implementation AddSongViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setEditing:TRUE animated:TRUE];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [GroupQClient sharedClient].library.songSectionNames.count;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[GroupQClient sharedClient].library.songSectionNames indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([(NSString*)obj isEqualToString:title])
            return TRUE;
        return FALSE;
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[GroupQClient sharedClient].library.songCollection objectAtIndex:section] count];
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[GroupQClient sharedClient].library.songSectionNames objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    MPMediaItem *songItem = [[[GroupQClient sharedClient].library.songCollection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = [songItem valueForProperty:MPMediaItemPropertyTitle];
    
    NSString *album = [songItem valueForProperty:MPMediaItemPropertyAlbumTitle];;
    
    NSString *artist = [songItem valueForProperty:MPMediaItemPropertyArtist];
    
    if ([album isEqualToString:@""]) {
        cell.detailTextLabel.text = artist;
    }
    else{
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",artist, album];
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        MPMediaItem *songItem = [[[GroupQClient sharedClient].library.songCollection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [[GroupQClient sharedClient].pickerSongs addObject:songItem];
    }   
}

- (IBAction)donePressed:(UIBarButtonItem *)sender {
    [[GroupQClient sharedClient].queue addSongs:[MPMediaItemCollection collectionWithItems:[GroupQClient sharedClient].pickerSongs]];
    [GroupQClient sharedClient].pickerSongs = nil;
    [[self parentViewController] performSegueWithIdentifier:@"doneWithPicker" sender:self];
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender{
    [GroupQClient sharedClient].pickerSongs = nil;
    [[self parentViewController] performSegueWithIdentifier:@"doneWithPicker" sender:self];
}
@end
