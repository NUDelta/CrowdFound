//
//  HelperDetailViewController.m
//  CrowdFound
//
//  Created by Yongsung on 11/13/14.
//  Copyright (c) 2014 YK. All rights reserved.
//

#import "HelperDetailViewController.h"
#import "CoreLocation/CoreLocation.h"
#import <Parse/Parse.h>
#import "RouteViewController.h"
#import "MyUser.h"

@interface HelperDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *item;
@property (weak, nonatomic) IBOutlet UILabel *locationDetail;
@property (weak, nonatomic) IBOutlet UILabel *itemDescription;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property BOOL helped;
@property BOOL helpFailed;
@property (weak, nonatomic) IBOutlet UILabel *helperNumber;
@property (weak, nonatomic) IBOutlet UILabel *helperFailNumber;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation HelperDetailViewController
- (IBAction)helpButton:(UIButton *)sender
{
    PFQuery *query = [PFQuery queryWithClassName:@"Request"];
    [query getObjectInBackgroundWithId:[self.request valueForKeyPath:@"objectId"] block:^(PFObject *object, NSError *error) {
        if (!error) {
            object[@"helper"] = [PFUser currentUser].username;
            object[@"helperId"] = [PFUser currentUser].objectId;
            NSMutableArray *array = [[NSMutableArray alloc] init];
            array = object[@"helpers"];
            [array addObject:[PFUser currentUser].objectId];
            object[@"helpers"] = array;
            if(!self.helped){
                int value = [object[@"helpCount"] intValue];
                NSNumber *helpCount = [NSNumber numberWithInt:value+1];
                object[@"helpCount"] = helpCount;
            }
            [object saveInBackground];
            self.helped = YES;
            NSString *str = [NSString stringWithFormat:@"%@ helped %@", [PFUser currentUser].username, self.item.text];
            [self appUsageLogging:str];
        } else {
            NSLog(@"ERROR!");
        }
        
    }];
}

//Help fail count
- (IBAction)noButton:(UIButton *)sender {
    if(!self.helpFailed){
        PFQuery *query = [PFQuery queryWithClassName:@"Request"];
        [query getObjectInBackgroundWithId:[self.request valueForKeyPath:@"objectId"] block:^(PFObject *object, NSError *error) {
            if (!error) {
                int helpFailCount = [object[@"helpFailCount"] intValue];
                NSLog(@"%d", helpFailCount);
                NSNumber *value = [NSNumber numberWithInt:helpFailCount+1];
                object[@"helpFailCount"] = value;
                [object saveInBackground];
                self.helpFailed = YES;
            } else {
                NSLog(@"ERROR!");
            }
        }];
    } else {
        NSLog(@"already clicked!");
    }
}

- (void)fillDetails
{
    self.item.text = [NSString stringWithFormat:@"%@", [self.request valueForKeyPath:@"item"]];
    [self.item sizeToFit];
    self.locationDetail.numberOfLines = 3;
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude: [[self.request valueForKeyPath:@"lat"] floatValue]
                                                longitude: [[self.request valueForKeyPath:@"lng"] floatValue]];
    
    [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
        
        if (error){
            NSLog(@"Geocode failed with error: %@", error);
            self.location.text = [NSString stringWithFormat:@"%f, %f", [[self.request valueForKeyPath:@"lat"] floatValue], [[self.request valueForKeyPath:@"lng"] floatValue]];
            return;
            
        }
        if(placemarks && placemarks.count > 0)
        {
            CLPlacemark *topResult = [placemarks objectAtIndex:0];
            NSString *addressTxt = [NSString stringWithFormat:@"%@ %@,%@ %@",
                                    [topResult subThoroughfare],[topResult thoroughfare],
                                    [topResult locality], [topResult administrativeArea]];
            NSLog(@"%@",addressTxt);
            self.location.text = [NSString stringWithFormat:@"%@", addressTxt];
            [self.location sizeToFit];
        }
    }];
    //    self.location.text = [NSString stringWithFormat:@"%f, %f", [[self.request valueForKeyPath:@"lat"] floatValue], [[self.request valueForKeyPath:@"lng"] floatValue]];
    self.locationDetail.text = [NSString stringWithFormat:@"%@", [self.request valueForKeyPath:@"locationDetail"]];
    [self.locationDetail sizeToFit];
    NSArray *arr = [[self.request valueForKeyPath:@"detail"] componentsSeparatedByString:@" "];
    NSMutableArray *muarr = [[NSMutableArray alloc]init];
    for(int i = 1; i <= [arr count]; i++) {
        if(i%6!=0)
        {
            [muarr addObject:arr[i-1]];
            [muarr addObject:@" "];
        }else{
            [muarr addObject:arr[i-1]];
            [muarr addObject:@" \n"];
        }
    }
    NSString *detailstring = [muarr componentsJoinedByString:@""];
    
    self.itemDescription.text = [NSString stringWithFormat:@"%@", [self.request valueForKeyPath:@"detail"]];
    self.itemDescription.text = [NSString stringWithFormat:@"%@", detailstring];
    [self.itemDescription sizeToFit];
    self.helperNumber.text = [NSString stringWithFormat:@"Helper number: %d", [[self.request valueForKeyPath:@"helpCount"] intValue]];
    self.helperFailNumber.text = [NSString stringWithFormat:@"Number of Helper couldn't find: %d", [[self.request valueForKeyPath:@"helpFailCount"] intValue]];
    // Do any additional setup after loading the view.
    
    PFQuery *query = [PFQuery queryWithClassName: @"Request"];
    [query whereKey:@"objectId" equalTo:[self.request valueForKeyPath:@"objectId"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            if([objects count]>0){
                self.request = objects[0];
                PFFile *imageFile = objects[0][@"image"];
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if(!error) {
                        UIImage *image = [UIImage imageWithData: data];
                        self.imageView.image = image;
                        NSLog(@"image!");
                        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
                        
                    }
                }];
            }
            
        }
    }];

}


- (void)viewDidLoad {
    [super viewDidLoad];

    if([self.request valueForKeyPath:@"item"] == NULL) {
        NSLog(@"it is empty! ID is %@", self.objectId);
        PFQuery *query = [PFQuery queryWithClassName: @"Request"];
        [query whereKey:@"objectId" equalTo:self.objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                if([objects count]>0){
                    self.request = objects[0];
                    NSLog(@"%@", [self.request valueForKeyPath:@"item"]);
                    [self fillDetails];
                }
                
            }
        }];
    } else {
        NSLog(@"not empty!");
        [self fillDetails];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)appUsageLogging: (NSString *)activity {
    PFObject *usage = [PFObject objectWithClassName:@"UsageLog"];
    usage[@"username"] = [MyUser currentUser].username;
    usage[@"userid"] = [MyUser currentUser].objectId;
    usage[@"activity"] = activity;
    [usage saveInBackground];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"RouteViewSegue"]) {
        RouteViewController *rvc = [segue destinationViewController];
        rvc.request = self.request;
    }
    
}


@end
