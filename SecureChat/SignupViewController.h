//
//  SignupViewController.h
//  SecureChat
//
//  Created by apple on 2015-07-14.
//  Copyright (c) 2015 YangTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignupViewController : UIViewController<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextField *cPassWordLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailLabel;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *inputs;

- (IBAction)resignAction:(id)sender;

- (IBAction)signupAction:(id)sender;
@end
