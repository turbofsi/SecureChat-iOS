//
//  EditFriendsViewController.m
//  SecureChat
//
//  Created by apple on 2015-07-14.
//  Copyright (c) 2015 YangTech. All rights reserved.
//

#import "EditFriendsViewController.h"
#import <Parse/Parse.h>

@interface EditFriendsViewController ()

@end

@implementation EditFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFQuery *query = [PFUser query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"Try again" otherButtonTitles: nil];
            [alertView show];
        } else {
            self.allUsers = objects;
            [self.tableView reloadData];
        }
    }];
    
    self.currentUser = [PFUser currentUser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_allUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellidentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellidentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
    }
    PFUser *user = [_allUsers objectAtIndex:indexPath.row];
    
    cell.textLabel.text = user.username;
    if ([self isFriends:user]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (BOOL)isFriends:(PFUser *)user {
    for (PFUser *friend in _friends) {
        if ([friend.objectId isEqualToString:user.objectId]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Tabel View delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    
    PFRelation *friendRelation = [_currentUser relationForKey:@"friendsRelation"];
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
    
    if ([self isFriends:user]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.friends removeObject:user];
        [friendRelation removeObject:user];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [friendRelation addObject:user];
        [self.friends addObject:user];
    }
    
    
    
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"Try again" otherButtonTitles: nil];
            [alertView show];
        } else {
            
        }
    }];
}











@end
