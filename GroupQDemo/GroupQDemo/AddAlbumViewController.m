//
//  AddAlbumViewController.m
//  GroupQDemo
//
//  Created by Parker Allen Tew on 4/7/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "AddAlbumViewController.h"

@interface AddAlbumViewController ()

@end

@implementation AddAlbumViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setEditing:TRUE animated:TRUE];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[GroupQClient sharedClient].library.albumSectionNames count];
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[GroupQClient sharedClient].library.albumSectionNames indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([(NSString*)obj isEqualToString:title])
            return TRUE;
        return FALSE;
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[GroupQClient sharedClient].library.albumCollection objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSString *album = ((iOSQueueItem*)[[[GroupQClient sharedClient].library.albumCollection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]).album;
    if (album.length == 0) {
        cell.textLabel.text = @"Untitled album";
    }
    else {
        cell.textLabel.text = album;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        NSArray *artistSongs = [[[GroupQClient sharedClient].library.albumCollection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [[GroupQClient sharedClient].pickerSongs addObjectsFromArray:artistSongs];
    }
}


- (IBAction)donePressed:(UIBarButtonItem *)sender {
    [[GroupQClient sharedClient].queue addSongs:[GroupQClient sharedClient].pickerSongs];
    [GroupQClient sharedClient].pickerSongs = nil;
    [[self parentViewController] performSegueWithIdentifier:@"doneWithPicker" sender:self];
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    [GroupQClient sharedClient].pickerSongs = nil;
    [[self parentViewController] performSegueWithIdentifier:@"doneWithPicker" sender:self];
}
@end
