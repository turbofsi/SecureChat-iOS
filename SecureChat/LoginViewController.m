//
//  LoginViewController.m
//  SecureChat
//
//  Created by apple on 2015-07-14.
//  Copyright (c) 2015 YangTech. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *imageView = (id)[self.view viewWithTag:102];
    [self.view sendSubviewToBack:imageView];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginAction:(id)sender {
    NSString *username = [_usernameLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [_passwordLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username isEqualToString:@""] || password.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please fill all blanks above!" delegate:nil cancelButtonTitle:@"Try again!" otherButtonTitles: nil];
        [alertView show];
    } else {
        //passing form validation
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error){
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oh no" message:[error.userInfo objectForKey:@"error"] delegate:self cancelButtonTitle:@"Try again" otherButtonTitles: nil];
                [alertView show];
            } else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
    
    
}

- (IBAction)showSignup:(id)sender {
    [self performSegueWithIdentifier:@"LogintoSignup" sender:self];
}


@end
