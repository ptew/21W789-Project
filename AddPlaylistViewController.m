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
@property (strong, nonatomic) NSMutableArray *addedItems;

@end

@implementation AddPlaylistViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.pickerTableView setEditing:TRUE animated:TRUE];
    
    self.pickerTableView.scrollsToTop = TRUE;
    self.pickerTableView.showsVerticalScrollIndicator = TRUE;
    
    self.addedItems = [[NSMutableArray alloc] init];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[GroupQClient sharedClient].library.playlistCollection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSString *playlistName = [[[[GroupQClient sharedClient].library.playlistCollection allKeys]sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = playlistName;
    
    if ([self.addedItems containsObject:playlistName]) {
        cell.textLabel.textColor = [UIColor grayColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        NSString *playlistName = [[[[GroupQClient sharedClient].library.playlistCollection allKeys]sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.row];
        
        NSArray *playlist = [[GroupQClient sharedClient].library.playlistCollection objectForKey:playlistName];
        [[GroupQClient sharedClient].pickerSongs addObjectsFromArray:playlist];
        [self.addedItems addObject:playlistName];
        [tableView reloadData];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  UITableViewCellEditingStyleInsert;
}

- (IBAction)donePressed:(UIBarButtonItem *)sender {
    if ([[GroupQClient sharedClient] isDJ]) {
        [[GroupQClient sharedClient] tellServerToAddSongs:[GroupQClient sharedClient].pickerSongs];
    }
    else {
        [[GroupQClient sharedClient] tellServerToRequestSongs:[GroupQClient sharedClient].pickerSongs];
    }
    [GroupQClient sharedClient].pickerSongs = [[NSMutableArray alloc] init];
    [[self parentViewController] performSegueWithIdentifier:@"doneWithPicker" sender:self];
    self.addedItems = [[NSMutableArray alloc] init];
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    [GroupQClient sharedClient].pickerSongs = [[NSMutableArray alloc] init];
    [[self parentViewController] performSegueWithIdentifier:@"doneWithPicker" sender:self];
    self.addedItems = [[NSMutableArray alloc] init];
}
@end
