//
//  CameraViewController.h
//  SecureChat
//
//  Created by apple on 2015-07-15.
//  Copyright (c) 2015 YangTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CameraViewController : UITableViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *videoPath;

@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic, strong) NSArray *friendsUsers;
@property (nonatomic, strong) NSMutableArray *recipients;

- (IBAction)cancelAction:(id)sender;
- (IBAction)sendAction:(id)sender;

- (void)uploadImageToParse;
- (UIImage *)resizeImage:(UIImage *)image WithWidth:(float)width andHeight:(float)height;

@end
