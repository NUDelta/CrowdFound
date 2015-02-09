//
//  SignUpViewController.m
//  CrowdFound
//
//  Created by Yongsung on 11/30/14.
//  Copyright (c) 2014 YK. All rights reserved.
//

#import "SignUpViewController.h"
#import "MyUser.h"
#import "AppDelegate.h"

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *reEnterPasswordField;
@property (weak, nonatomic) IBOutlet UIButton *registerAction;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *residenceHallField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;

@end

@implementation SignUpViewController

- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:self completion:NULL];
}

- (IBAction)registerAction:(UIButton *)sender {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.emailField resignFirstResponder];
    [self.reEnterPasswordField resignFirstResponder];
    [self checkFieldsComplete];
    NSLog(@"good");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    MyUser *user = (MyUser *)[MyUser currentUser];
    //    PFUser *user = [PFUser currentUser];
    NSLog(@"current user name%@", user.username);
    if( user.username != nil) {
        [self performSegueWithIdentifier:@"Login" sender:self];
    }
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    self.reEnterPasswordField.delegate = self;
    self.emailField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) checkFieldsComplete
{
    if ([self.usernameField.text isEqualToString:@""] || [self.emailField.text isEqualToString:@""] || [self.passwordField.text isEqualToString:@""] || [self.reEnterPasswordField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"You need to complete all fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        [self checkPasswordsMatch];
    }
}

- (void) checkPasswordsMatch { //check users entered passwords match
    if (![_passwordField.text isEqualToString:_reEnterPasswordField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oooopss!" message:@"Passwords don't match" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else {
        [self registerNewUser];
    }
}

- (void) registerNewUser {
    //    PFUser *newUser = [PFUser user];
    MyUser *newUser = (MyUser *)[MyUser object];
    newUser.username = self.usernameField.text;
    newUser.email = self.emailField.text;
    [newUser setAdditional: self.phoneNumberField.text];
    newUser.password = self.passwordField.text;
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Registration success!");
            self.usernameField.text =@"";
            self.emailField.text = @"";
            self.passwordField.text = @"";
            self.reEnterPasswordField.text = @"";
            self.phoneNumberField.text = @"";
            AppDelegate *appDelegateTemp = [[UIApplication sharedApplication]delegate];
            PFInstallation *installation = [PFInstallation currentInstallation];
            installation[@"user"] = [PFUser currentUser];
            [installation saveInBackground];
            [self dismissViewControllerAnimated:YES completion:NULL];
            appDelegateTemp.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oooopss!" message:[NSString stringWithFormat:@"Error message: %@", error.description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            NSLog(@"There was an error in registration");
        }
    }];
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
