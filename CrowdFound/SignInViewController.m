//
//  SignInViewController.m
//  CrowdFound
//
//  Created by Yongsung on 11/30/14.
//  Copyright (c) 2014 YK. All rights reserved.
//

#import "SignInViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface SignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation SignInViewController
- (IBAction)logInButton:(UIButton *)sender
{
    [PFUser logInWithUsernameInBackground:self.username.text password:self.password.text
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            AppDelegate *appDelegateTemp = [[UIApplication sharedApplication]delegate];
                                            appDelegateTemp.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
                                            
                                            // Do stuff after successful login.
                                        } else {
                                            // The login failed. Check error to see why.
                                        }
                                    }];
}
- (IBAction)signUpButton:(UIButton *)sender
{
    UIViewController* logInViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    [self presentViewController:logInViewController animated:NO completion:NULL];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.username.delegate =self;
    self.password.delegate = self;
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

@end
