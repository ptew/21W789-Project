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
@property (weak, nonatomic) UIActionSheet *songActionSheet;
@property (weak, nonatomic) UIActionSheet *errorActionSheet;
@end

@implementation SpotifySearchViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark SpotifySearher methods

- (void) searchReturnedResults:(NSArray *)results {
    self.searchResults = results.copy;
    [self.tableView reloadData];
}

- (void) searchResultedInError {
    self.errorActionSheet = [[UIActionSheet alloc] initWithTitle:@"An Error Occored" delegate:self cancelButtonTitle:@"Try Again" destructiveButtonTitle:nil otherButtonTitles:nil, nil, nil];
}

#pragma mark SearchBar delegate methods

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [[SpotifySearcher sharedSearcher] search:searchBar.text];
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
    if (self.searchResults == nil){
        return 0;
    }
    else {
        return self.searchResults.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    SpotifyQueueItem *song = [[GroupQClient sharedClient].queue.queuedSongs objectAtIndex:indexPath.row];
    NSString * title   = song.title;
    NSString * album   = song.album;
    NSString * artist  = song.artist;
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",artist, album];
    
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
        self.songActionSheet = [[UIActionSheet alloc] initWithTitle:@"Queue Item Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add to Queue", nil, nil];
        [self.songActionSheet showInView:[self.tableView window]];
    }
    
    [self.tableView reloadData];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UIActionSheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([actionSheet isEqual:self.songActionSheet]){
    switch (buttonIndex) {
        case 1:
            //Add to Queue Button
            [[GroupQClient sharedClient] tellServerToaddSpotifySong:[self.searchResults objectAtIndex:self.currentlySelectedSong.row]];
            [self performSegueWithIdentifier:@"doneWithSpotify" sender:self];
            break;
        default:
            break;
    }
    }
    else if([actionSheet isEqual:self.errorActionSheet]){
        //do error handling if needed.
    }
}

@end
