//
//  InboxViewController.m
//  SecureChat
//
//  Created by apple on 2015-07-12.
//  Copyright (c) 2015 YangTech. All rights reserved.
//

#import "InboxViewController.h"
#import <SAMGradientView/SAMGradientView.h>
#import <HexColors/HexColors.h>
#import <Parse/Parse.h>
#import "ImageViewController.h"
#import <MSCellAccessory/MSCellAccessory.h>
@interface InboxViewController ()

@end

@implementation InboxViewController

@dynamic refreshControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.videoPlayer = [[MPMoviePlayerController alloc] init];
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSLog(@"%@", currentUser.username);
    } else {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(recieveMessage) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSLog(@"%@", currentUser.username);
        NSString *title = [NSString stringWithFormat:@"%@'s Inbox", currentUser.username];
        self.navigationItem.title = title;
    }
    [self recieveMessage];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.messages = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showLogin"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    } else if ([segue.identifier isEqualToString:@"showImage"]) {
        ImageViewController *viewController = segue.destinationViewController;
        viewController.message = _selectedMessage;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellidentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
    }
    
    PFObject *message = _messages[indexPath.row];
    cell.textLabel.text = [message objectForKey:@"senderName"];
    if ([[message objectForKey:@"fileType"] isEqualToString:@"image"]) {
        cell.imageView.image = [UIImage imageNamed:@"icon_image"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"icon_video"];
    }
    
    UIColor *cellAccessoryColor1 = [UIColor colorWithHexString:@"#D35400"];
    
    cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:cellAccessoryColor1];
    return cell;
}


#pragma mark - tabel view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *message = _messages[indexPath.row];
    NSString *fileType = [message objectForKey:@"fileType"];
    self.selectedMessage = message;
    if ([fileType isEqualToString:@"image"]) {
        [self performSegueWithIdentifier:@"showImage" sender:nil];
    } else {
        PFFile *videoFile = [message objectForKey:@"file"];
        NSURL *videoURL = [NSURL URLWithString:videoFile.url];
        [_videoPlayer setContentURL:videoURL];
        [_videoPlayer prepareToPlay];
        
        [self.view addSubview:_videoPlayer.view];
        [_videoPlayer setFullscreen:YES animated:YES];
    }
    
    NSMutableArray *recipientsIds = [NSMutableArray arrayWithArray:[self.selectedMessage objectForKey:@"recipientsIds"]];
    if ([recipientsIds count] == 1) {
        //deleting the whole message instance
        [self.selectedMessage deleteInBackground];
    } else {
        //remove this recipients from that message instance
        [recipientsIds removeObject:[[PFUser currentUser] objectId]];
        [self.selectedMessage setObject:recipientsIds forKey:@"recipientsIds"];
        [self.selectedMessage saveInBackground];
    }
}


- (IBAction)logoutAction:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}




#pragma mark - helper methods
- (void)recieveMessage {
    if ([PFUser currentUser] != nil) {
        PFQuery *query = [PFQuery queryWithClassName:@"Message"];
        [query whereKey:@"recipientsIds" equalTo:[[PFUser currentUser] objectId]];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if (error) {
                NSLog(@"error: %@", [error.userInfo objectForKey:@"error"]);
            } else {
                self.messages = objects;
                [self.tableView reloadData];
            }
            if ([self.refreshControl isRefreshing]) {
                [self.refreshControl endRefreshing];
            }
        }];
    }
}





@end
