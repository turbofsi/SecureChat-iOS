//
//  FriendsViewController.h
//  SecureChat
//
//  Created by apple on 2015-07-15.
//  Copyright (c) 2015 YangTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FriendsViewController : UITableViewController

@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic, strong) NSArray *friendsUsers;

@end
