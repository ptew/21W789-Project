//
//  SpotifySearchViewController.m
//  GroupQDemo
//
//  Created by T. S. Cobb on 4/7/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "SpotifySearchViewController.h"

@interface SpotifySearchViewController ()
@property (strong, nonatomic) NSIndexPath *currentlySelectedSong;
@property (strong, nonatomic) UIActionSheet *songActionSheet;
@property (strong, nonatomic) UIActionSheet *errorActionSheet;
@property bool isSearching;
@end

@implementation SpotifySearchViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[SpotifySearcher sharedSearcher] setDelegate:self];
    
    [self.searchText becomeFirstResponder];
    
    //enable cancel button always.
    for ( id subview in self.searchText.subviews){
        if ([subview isKindOfClass:[UIButton class]]) {
            [subview setEnabled:YES];
        }
    }
    
    self.isSearching = false;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"Hiding status bar.");
}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"Showing status bar.");
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark SpotifySearher methods

- (void) searchReturnedResults:(NSArray *)results {
    self.isSearching = false;
    self.searchResults = [NSArray alloc];
    if(results.count > 0){
        self.searchResults = [self.searchResults initWithArray:results.copy];
    }
    else{
        self.searchResults = nil;
    }
    [self.tableView reloadData];
}

- (void) searchResultedInError {
    self.isSearching = false;
    NSLog(@"Search error");
    self.errorActionSheet = [[UIActionSheet alloc] initWithTitle:@"An Error Occored" delegate:self cancelButtonTitle:@"Try Again" destructiveButtonTitle:nil otherButtonTitles:nil, nil, nil];
    [self.tableView reloadData];
}

#pragma mark SearchBar delegate methods

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [[SpotifySearcher sharedSearcher] search:searchBar.text];
    self.isSearching = true;
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self performSegueWithIdentifier:@"doneWithSpotify" sender:self];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchResults == nil || self.isSearching){
        return 1;
    }
    else {
        if (self.searchResults.count > 10)
            return 10;
        else
            return self.searchResults.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if(self.isSearching) {
        if(indexPath.row == 0) {
            cell.textLabel.text = @"Searching...";
            cell.detailTextLabel.text = @"";
            cell.textLabel.textColor = [UIColor grayColor];
        }
    }
    else if(self.searchResults == nil){
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Search Returned No Results";
            cell.detailTextLabel.text = @"";
            cell.textLabel.textColor = [UIColor grayColor];
        }
    }
    else {
        SpotifyQueueItem *song = [self.searchResults objectAtIndex:indexPath.row];
        NSString * title   = song.title;
        NSString * album   = song.album;
        NSString * artist  = song.artist;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.text = title;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",artist, album];
    }
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //////////////////////////////////////////////////////
    //Want to add the selected song to the queue call add spotify song to server.
    
    self.currentlySelectedSong = indexPath;
    if (self.songActionSheet) {
        // do nothing
    } else {
        if ([[GroupQClient sharedClient] isDJ]) {
            self.songActionSheet = [[UIActionSheet alloc] initWithTitle:@"Song Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add to Queue", nil, nil];
        }
        else {
            self.songActionSheet = [[UIActionSheet alloc] initWithTitle:@"Song Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Request Song", nil, nil];
        }
        [self.songActionSheet showInView:[self.tableView window]];
    }
    
    [self.tableView reloadData];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UIActionSheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonText = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([actionSheet isEqual:self.songActionSheet]){
        if([buttonText isEqualToString:@"Add to Queue"]) {
            //Add to Queue Button
            [[GroupQClient sharedClient] tellServerToAddSpotifySong:[self.searchResults objectAtIndex:self.currentlySelectedSong.row]];
            [self performSegueWithIdentifier:@"doneWithSpotify" sender:self];
        }
        else if([buttonText isEqualToString:@"Request Song"]) {
            [[GroupQClient sharedClient] tellServerToRequestSongs:[NSArray arrayWithObject:[self.searchResults objectAtIndex:self.currentlySelectedSong.row]]];
            [self performSegueWithIdentifier:@"doneWithSpotify" sender:self];
        }
    }
    else if([actionSheet isEqual:self.errorActionSheet]){
        //do error handling if needed.
    }
}

@end
