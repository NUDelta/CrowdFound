//
//  RequestDetailViewController.m
//  CrowdFound
//
//  Created by Yongsung on 11/10/14.
//  Copyright (c) 2014 YK. All rights reserved.
//

#import "RequestDetailViewController.h"
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "AddLocationViewController.h"
#import "MyUser.h"

@interface RequestDetailViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *descItemTextField;
@property (weak, nonatomic) IBOutlet UITextField *itemTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationDetail;
@property (weak, nonatomic) IBOutlet UILabel *lostItemLocation;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

CGFloat animatedDistance;
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@implementation RequestDetailViewController
- (IBAction)chooseImageButton:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Choose image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a photo",@"Select a photo", nil];
    [actionSheet showInView:self.view];
}



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //take a photo
    if (buttonIndex == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
    } else if (buttonIndex ==1 ){ //select a photo
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:NULL];
    }
    NSLog(@"clicked %d", buttonIndex);
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"here");
//    [self animateTextField: textField up: YES];
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    [self animateTextField: textField up: NO];
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}


//- (void) animateTextField: (UITextField*) textField up: (BOOL) up
//{
//    const int movementDistance = 100; // tweak as needed
//    const float movementDuration = 0.3f; // tweak as needed
//    
//    int movement = (up ? -movementDistance : movementDistance);
//    
//    [UIView beginAnimations: @"anim" context: nil];
//    [UIView setAnimationBeginsFromCurrentState: YES];
//    [UIView setAnimationDuration: movementDuration];
//    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
//    [UIView commitAnimations];
//}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender
{
    [self.locationDetail resignFirstResponder];
    [self.itemTextField resignFirstResponder];
    [self.descItemTextField resignFirstResponder];
}
- (IBAction)submit:(UIButton *)sender {
    [self saveRequest];
}
- (IBAction)indexChanged:(id)sender {
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
            [self.tabBarController setSelectedIndex:0];
            break;
        case 1:
            [self.tabBarController setSelectedIndex:1];
            break;
        default: 
            break; 
    }
}


//unwind segue from AddLocationViewController
- (IBAction)completeAddLocation: (UIStoryboardSegue *)segue
{
    NSLog(@"completeAddLocation");
    AddLocationViewController *alvc = segue.sourceViewController;
    self.annotations = alvc.annotations;
    for (id <MKAnnotation> annotation in self.annotations) {
//        self.locationDetail.text = [[NSString alloc] initWithFormat:@"%f, %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        CLLocation *loc = [[CLLocation alloc]initWithLatitude: annotation.coordinate.latitude
                                                    longitude: annotation.coordinate.longitude];
        
        [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
            NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
            
            if (error){
                NSLog(@"Geocode failed with error: %@", error);
                self.lostItemLocation.text = [NSString stringWithFormat:@"%f, %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
                return;
                
            }
            if(placemarks && placemarks.count > 0) {
                CLPlacemark *topResult = [placemarks objectAtIndex:0];
                NSString *addressTxt = [NSString stringWithFormat:@"%@,%@ %@",
                                        [topResult thoroughfare],
                                        [topResult locality], [topResult administrativeArea]];
                NSLog(@"%@",addressTxt);
                self.lostItemLocation.text = [NSString stringWithFormat:@"%@", addressTxt];
                [self.lostItemLocation sizeToFit];
            }
        }];
//        self.lostItemLocation.text = [[NSString alloc] initWithFormat:@"%f, %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
    }

}


- (void)saveRequest
{
    for (id <MKAnnotation> annotation in self.annotations) {
        if([annotation isKindOfClass:[MKUserLocation class]]) continue;
        NSLog(@"%f", annotation.coordinate.latitude);
        PFObject *lostItem = [PFObject objectWithClassName:@"Request"];
        if (self.imageView.image != NULL) {
            NSData* data = UIImageJPEGRepresentation(self.imageView.image, 0.5f);
            PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
            [lostItem setObject:imageFile forKey:@"image"];
        }
        NSLog(@"item name: %@", self.itemTextField.text);
        lostItem[@"item"] = self.itemTextField.text;
        lostItem[@"detail"] = self.descItemTextField.text;
        lostItem[@"locationDetail"] = self.locationDetail.text;
        lostItem[@"locDetail"] = self.lostItemLocation.text;
        lostItem[@"lat"] =  [[NSString alloc] initWithFormat:@"%f", annotation.coordinate.latitude];
        lostItem[@"lng"] = [[NSString alloc] initWithFormat:@"%f", annotation.coordinate.longitude];
        lostItem[@"username"] = [MyUser currentUser].username;
        lostItem[@"email"] = [MyUser currentUser].email;
        lostItem[@"helper"] = @"";
        lostItem[@"helperId"] = @"";
        NSArray *array = [[NSArray alloc]init];
        lostItem[@"helpers"] = array;
        [lostItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded) {
                self.locationDetail.text = @"";
                self.itemTextField.text = @"";
                //        self.locationDetail.text = @"";
                self.lostItemLocation.text = @"";
                self.descItemTextField.text = @"";
                self.imageView.image = nil;
                [self.tabBarController setSelectedIndex:0];
            }
        }];
    }

//    UINavigationController *navController = self.navigationController;
//    [navController popViewControllerAnimated:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.descItemTextField.delegate = self;
    self.itemTextField.delegate = self;
    self.locationDetail.delegate = self;
    [self showAnnotations];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.segmentedControl.selectedSegmentIndex = 1;
}
- (void)showAnnotations
{
    for (id <MKAnnotation> annotation in self.annotations) {
        NSLog(@"%f", annotation.coordinate.latitude);
    }
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
