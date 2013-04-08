//
//  AddArtistViewController.m
//  GroupQDemo
//
//  Created by Parker Allen Tew on 4/7/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "AddArtistViewController.h"

@interface AddArtistViewController ()

@end

@implementation AddArtistViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setEditing:TRUE animated:TRUE];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfSections = [GroupQClient sharedClient].ipodArtists.itemSections.count;
    return numberOfSections > 0 ? numberOfSections : 1;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    __block NSInteger sectionIndex = 0;
    [[[GroupQClient sharedClient].ipodArtists itemSections] enumerateObjectsUsingBlock:^(MPMediaQuerySection *querySection, NSUInteger idx, BOOL *stop) {
        if([[querySection title] isEqualToString:title]) {
            sectionIndex = idx;
            *stop = YES;
        }
    }];
    
    return sectionIndex;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = [GroupQClient sharedClient].ipodArtists.items.count;
    if([GroupQClient sharedClient].ipodArtists.itemSections.count) {
        MPMediaQuerySection *querySection = [[[GroupQClient sharedClient].ipodArtists itemSections] objectAtIndex:section];
        numberOfRows = querySection.range.length;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = [[[[[GroupQClient sharedClient].ipodArtists collections] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] valueForProperty:MPMediaItemPropertyArtist];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        [[GroupQClient sharedClient].pickerSongs addObject:[[[[GroupQClient sharedClient].ipodArtists collections] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    }   
}


- (IBAction)donePressed:(UIBarButtonItem *)sender {
    [[GroupQClient sharedClient].queue addSongs:[MPMediaItemCollection collectionWithItems:[GroupQClient sharedClient].pickerSongs]];
    [GroupQClient sharedClient].pickerSongs = nil;
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    [GroupQClient sharedClient].pickerSongs = nil;
}
@end
