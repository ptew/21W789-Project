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
    [self.pickerTableView setEditing:TRUE animated:TRUE];
    
    self.pickerTableView.scrollsToTop = TRUE;
    self.pickerTableView.showsVerticalScrollIndicator = TRUE;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[GroupQClient sharedClient].library.albumSectionNames count];
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    return [GroupQClient sharedClient].library.albumSectionNames;
    
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[GroupQClient sharedClient].library.albumSectionNames objectAtIndex:section];
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
    return ((NSMutableDictionary*)[[GroupQClient sharedClient].library.albumCollection objectAtIndex:section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    id albumsBeginningWithSectionLetter = [[GroupQClient sharedClient].library.albumCollection objectAtIndex:indexPath.section];
    NSArray *albumNames = [albumsBeginningWithSectionLetter allKeys];
    NSArray *sortedAlbumNames = [albumNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSString *albumName = [sortedAlbumNames objectAtIndex:indexPath.row];
    cell.textLabel.text = albumName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        NSMutableDictionary *albumsBeginningWithSectionLetter = [[GroupQClient sharedClient].library.albumCollection objectAtIndex:indexPath.section];
        NSArray *albumNames = [albumsBeginningWithSectionLetter allKeys];
        NSArray *sortedAlbumNames = [albumNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSString *albumName = [sortedAlbumNames objectAtIndex:indexPath.row];
        NSArray *albumSongs = [albumsBeginningWithSectionLetter objectForKey:albumName];

        [[GroupQClient sharedClient].pickerSongs addObjectsFromArray:albumSongs];
        
        [self.pickerTableView cellForRowAtIndexPath:indexPath].textLabel.textColor = [UIColor grayColor];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  UITableViewCellEditingStyleInsert;
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
