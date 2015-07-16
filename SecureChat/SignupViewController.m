//
//  SignupViewController.m
//  SecureChat
//
//  Created by apple on 2015-07-14.
//  Copyright (c) 2015 YangTech. All rights reserved.
//

#import "SignupViewController.h"
#import <Parse/Parse.h>

@interface SignupViewController ()

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)resignAction:(id)sender {
    for (UITextField *textField in self.inputs) {
        [textField resignFirstResponder];
    }
}

- (IBAction)signupAction:(id)sender {
    NSString *username = [_userLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email = [_emailLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [_passwordLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *cpass = [_cPassWordLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username isEqual:@""] || [password isEqual:@""] || [cpass isEqual:@""] || [email isEqual:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please fill all blanks above" delegate:self cancelButtonTitle:@"Try again" otherButtonTitles: nil];
        [alertView show];
    } else if (![password isEqual:cpass]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Passwords didn't match" delegate:self cancelButtonTitle:@"Try again" otherButtonTitles: nil];
        [alertView show];
    } else { //passing front end form validation
        PFUser *user = [PFUser user];
        user.username = username;
        user.password = password;
        user.email = email;
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:[error.userInfo objectForKey:@"error"] delegate:self cancelButtonTitle:@"Try again" otherButtonTitles: nil];
                [alertView show];
            } else {
                
                [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error){
                    if (error) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oh no" message:@"Please contact us" delegate:nil cancelButtonTitle:@"Try again" otherButtonTitles: nil];
                        [alertView show];
                    } else {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                }];
                
                
            }
        }];
    }
    
                       
}








@end
