//
//  LoginViewController.h
//  SecureChat
//
//  Created by apple on 2015-07-14.
//  Copyright (c) 2015 YangTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;

- (IBAction)loginAction:(id)sender;
- (IBAction)showSignup:(id)sender;

@end
