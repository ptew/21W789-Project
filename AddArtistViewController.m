//
//  AddArtistViewController.m
//  GroupQDemo
//
//  Created by Parker Allen Tew on 4/7/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "AddArtistViewController.h"

@interface AddArtistViewController ()

@property (strong, nonatomic) NSMutableArray *addedItems;

@end

@implementation AddArtistViewController

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
    return [[GroupQClient sharedClient].library.artistSectionNames count];

}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    return [GroupQClient sharedClient].library.artistSectionNames;
    
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[GroupQClient sharedClient].library.artistSectionNames objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[GroupQClient sharedClient].library.artistSectionNames indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([(NSString*)obj isEqualToString:title])
            return TRUE;
        return FALSE;
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSMutableDictionary*)[[GroupQClient sharedClient].library.artistCollection objectAtIndex:section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    id artistsBeginningWithSectionLetter = [[GroupQClient sharedClient].library.artistCollection objectAtIndex:indexPath.section];
    NSArray *artistNames = [artistsBeginningWithSectionLetter allKeys];
    NSArray *sortedArtistNames = [artistNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSString *artistName = [sortedArtistNames objectAtIndex:indexPath.row];
    cell.textLabel.text = artistName;
    
    if ([self.addedItems containsObject:artistName]) {
        cell.textLabel.textColor = [UIColor grayColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        NSMutableDictionary *artistsBeginningWithSectionLetter = (NSMutableDictionary *)[[GroupQClient sharedClient].library.artistCollection objectAtIndex:indexPath.section];
        NSArray *artistNames = [artistsBeginningWithSectionLetter allKeys];
        NSArray *sortedArtistNames = [artistNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSString *artistName = [sortedArtistNames objectAtIndex:indexPath.row];
        NSArray *artistSongs = [artistsBeginningWithSectionLetter objectForKey:artistName];
        [[GroupQClient sharedClient].pickerSongs addObjectsFromArray:artistSongs];
        [self.addedItems addObject:artistName];
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
