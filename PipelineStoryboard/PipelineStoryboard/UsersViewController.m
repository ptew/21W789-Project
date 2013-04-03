//
//  UsersViewController.m
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/1/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "UsersViewController.h"

@interface UsersViewController ()


- (IBAction)endEvent:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;
@property (weak, nonatomic) IBOutlet UITableView *userTable;
@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) NSNetService *netService;
@end

@implementation UsersViewController

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
    self.users = [[NSMutableArray alloc] init];
    self.navBar.title = self.eventName;
    
    self.netService = [[NSNetService alloc] initWithDomain:@"" type:@"_groupq._tcp" name:self.eventName port:9876];
    self.netService.delegate = self;
    [self.netService publish];
}

-(void)netService:(NSNetService *)aNetService
    didNotPublish:(NSDictionary *)dict {
    NSLog(@"Service did not publish: %@", dict);
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.netService stop];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        NSLog(@"User count: %d", self.users.count);
        return self.users.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSLog(@"Cell %d's text: %@", indexPath.row, [self.users objectAtIndex:indexPath.row]);
    cell.textLabel.text = [self.users objectAtIndex:indexPath.row];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Connected Users";
    }
    return @"";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (IBAction)endEvent:(UIBarButtonItem *)sender {
    [((UINavigationController *)self.parentViewController) popViewControllerAnimated:YES];
}
@end
