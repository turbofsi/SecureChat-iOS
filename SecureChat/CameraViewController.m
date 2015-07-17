//
//  CameraViewController.m
//  SecureChat
//
//  Created by apple on 2015-07-15.
//  Copyright (c) 2015 YangTech. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface CameraViewController ()

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //Set Friends data source
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];
    PFQuery *query = [self.friendsRelation query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"%@", [error.userInfo objectForKey:@"error"]);
        } else {
            _friendsUsers = objects;
            NSLog(@"FriendsView load Friends: %@", _friendsUsers);
            [self.tableView reloadData];
        }
    }];
    
    if (self.image == nil && self.videoPath.length == 0) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.allowsEditing = NO;
        self.imagePicker.videoMaximumDuration = 10;
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        } else {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
    
        self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePicker.sourceType];
    
        [self presentViewController:self.imagePicker animated:NO completion:nil];
    }
    
    self.recipients = [[NSMutableArray alloc] init];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.image = nil;
    self.videoPath = @"";
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
    return [_friendsUsers count];
}

#pragma mark - UIimagePicker delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.tabBarController setSelectedIndex:0];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *) kUTTypeImage]) {
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            //Saving the image!
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        }
    } else {
        self.videoPath = (__bridge NSString *)([[info objectForKey:UIImagePickerControllerMediaURL] path]);
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoPath)) {
                //Saving the video!
                UISaveVideoAtPathToSavedPhotosAlbum(self.videoPath, nil, nil, nil);
            }
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellidentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
    }
    // Configure the cell...
    PFUser *user = self.friendsUsers[indexPath.row];
    cell.textLabel.text = user.username;
    
    if ([_recipients containsObject:user.objectId]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    PFUser *friend = [self.friendsUsers objectAtIndex:indexPath.row];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.recipients removeObject:friend.objectId];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.recipients addObject:friend.objectId];
    }
    
}


- (void)resetProperty {
    self.image = nil;
    self.videoPath = nil;
    self.recipients = nil;
}

- (IBAction)cancelAction:(id)sender {
    [self resetProperty];
    
    [self.tabBarController setSelectedIndex:0];
}

- (IBAction)sendAction:(id)sender {
    if (self.image == nil && [self.videoPath isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please make sure to select photos and videos" delegate:self cancelButtonTitle:@"Try again" otherButtonTitles: nil];
        alertView.tag = 101;
        [alertView show];
    } else {
        //resize the image and send it
        [self uploadImageToParse];
        [self.tabBarController setSelectedIndex:0];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 101) {
        [self presentViewController:self.imagePicker animated:NO completion:nil];
    }
}


#pragma mark - upload image to parse
- (void)uploadImageToParse {
    
    NSData *fileData;
    NSString *fileName;
    NSString *fileType;
    
    if (self.image != nil) {
        UIImage *uploadImage = [self resizeImage:self.image WithWidth:self.view.bounds.size.width andHeight:self.view.bounds.size.height];
        fileData = UIImagePNGRepresentation(uploadImage);
        fileName = @"image.png";
        fileType = @"image";
    } else {
        fileData = [NSData dataWithContentsOfFile:self.videoPath];
        fileName = @"video.mov";
        fileType = @"video";
    }
    
    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    [file saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"Try again" otherButtonTitles: nil];
            [alertView show];
        } else {
            PFObject *message = [PFObject objectWithClassName:@"Message"];
            [message setObject:file forKey:@"file"];
            [message setObject:fileType forKey:@"fileType"];
            [message setObject:self.recipients forKey:@"recipientsIds"];
            [message setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
            [message setObject:[[PFUser currentUser] username] forKey:@"senderName"];
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"Try again" otherButtonTitles: nil];
                    [alertView show];
                } else {
                    //uploading files successful
                    [self resetProperty];
                }
            }];
        }
    }];
}

-(UIImage *)resizeImage:(UIImage *)image WithWidth:(float)width andHeight:(float)height {
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRect =  CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:newRect];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

@end
