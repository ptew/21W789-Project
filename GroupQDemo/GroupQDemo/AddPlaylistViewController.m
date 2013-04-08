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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  UITableViewCellEditingStyleInsert;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"There are %d rows in playlists", [[GroupQClient sharedClient].library.playlistSectionNames count]);
    return [[GroupQClient sharedClient].library.playlistSectionNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [[GroupQClient sharedClient].library.playlistSectionNames objectAtIndex:indexPath.row];
    
    NSLog(@"Playlist title: %@", cell.textLabel.text);
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        NSArray *playlist = [[GroupQClient sharedClient].library.playlistCollection objectAtIndex:indexPath.row];
        [[GroupQClient sharedClient].pickerSongs addObjectsFromArray:playlist];
    }
}

- (IBAction)donePressed:(UIBarButtonItem *)sender {
    [[GroupQClient sharedClient] tellServerToAddSongs:[GroupQClient sharedClient].pickerSongs];
    [GroupQClient sharedClient].pickerSongs = [[NSMutableArray alloc] init];
    [[self parentViewController] performSegueWithIdentifier:@"doneWithPicker" sender:self];
    
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    [GroupQClient sharedClient].pickerSongs = [[NSMutableArray alloc] init];
    [[self parentViewController] performSegueWithIdentifier:@"doneWithPicker" sender:self];
}
@end
