//
//  RouteViewController.m
//  CrowdFound
//
//  Created by Yongsung on 11/29/14.
//  Copyright (c) 2014 YK. All rights reserved.
//

#import "RouteViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import "MyUser.h" 

@interface RouteViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MKPointAnnotation *startPin;
@property (strong, nonatomic) MKPointAnnotation *destPin;
@property (strong, nonatomic) MKPolyline *routeLine;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property BOOL helped;
@property BOOL helpFailed;

@end

@implementation RouteViewController
- (IBAction)foundButton:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Have you found the item?" message:@"Click YES will send automated email to the requester." delegate:self cancelButtonTitle:@"NO" otherButtonTitles: nil];
    [alert addButtonWithTitle:@"YES"];
    [alert show];
    NSString *str = [NSString stringWithFormat:@"%@ found", [PFUser currentUser].username];
    [self appUsageLogging:str];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex!= alertView.cancelButtonIndex){
        NSLog(@"clicked okay");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Thank you for finding the item!" message:@"Requester will contact you to set up a meeting place." delegate:self cancelButtonTitle:@"OKAY" otherButtonTitles:nil];
        [alert show];
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self dropOffEmail];
    }
}

- (IBAction)notFoundButton:(UIButton *)sender {
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
                NSString *str = [NSString stringWithFormat:@"%@ couldn't found", [PFUser currentUser].username];
                [self appUsageLogging:str];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CrowdFound" message:@"Thanks for your time and effort!" delegate:self cancelButtonTitle:@"OKAY" otherButtonTitles:nil];
                [alert show];
                [self.navigationController popToRootViewControllerAnimated:YES];
            } else {
                NSLog(@"ERROR!");
            }
        }];
    } else {
        NSLog(@"already clicked!");
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mapView.delegate = self;
    self.startPin = [[MKPointAnnotation alloc]init];
//    CLLocationDegrees plexLat = 42.012893;
//    CLLocationDegrees plexLng = -87.578309;
//    CLLocationCoordinate2D plex = CLLocationCoordinate2DMake(plexLat, plexLng);
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
            CLLocationDegrees plexLat = geoPoint.latitude;
            CLLocationDegrees plexLng = geoPoint.longitude;
            CLLocationCoordinate2D plex = CLLocationCoordinate2DMake(plexLat, plexLng);
            self.startPin.coordinate = plex;
            self.startPin.title = @"Your location";
            [self.mapView addAnnotation: self.startPin];
            [self.mapView addAnnotation:self.startPin];
            CLLocationDegrees destLat = [[self.request valueForKeyPath:@"lat"] floatValue];
            CLLocationDegrees destLng =[[self.request valueForKeyPath:@"lng"] floatValue];
            
            CLLocationCoordinate2D delta = CLLocationCoordinate2DMake(destLat, destLng);
            self.destPin = [[MKPointAnnotation alloc] init];
            self.destPin.coordinate = delta;
            self.destPin.title = [self.request valueForKey:@"item"];
            [self.mapView addAnnotation: self.destPin];
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (self.startPin.coordinate, 1000, 1000);
            [self.mapView setRegion:region animated:NO];
            [self drawRoute];
            
            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
            [[PFUser currentUser] saveInBackground];
        }
    }];
//    self.startPin.coordinate = plex;
//    self.startPin.title = @"Plex";
//    [self.mapView addAnnotation: self.startPin];
//    [self.mapView addAnnotation:self.startPin];
    
    self.mapView.showsUserLocation = YES;
}


- (void)dropOffEmail
{
    NSError *error;
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil            ];
    
    NSURL * url = [NSURL URLWithString:@"http://crowdfound.parseapp.com/dropoff_email"];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString * params = [NSString stringWithFormat:@"name=%@&phone=%@&reqName=%@&email=%@",[PFUser currentUser].username, [PFUser currentUser].email, [self.request valueForKeyPath:@"username"], [self.request valueForKeyPath:@"email"]];
    NSLog(@"==============email===============, %@", [self.request valueForKeyPath:@"email"]);
    //TODO change email address and username
    
    //    NSString * params = [NSString stringWithFormat:@"name=%@&phone=yk@u.northwestern.edu&reqName=%@&email=%@",[PFUser currentUser].username, [self.request valueForKeyPath:@"username"], [self.request valueForKeyPath:@"email"]];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    //    NSDictionary *mapData = [[NSDictionary alloc] initWithObjectsAndKeys: @"tester", @"name", nil];
    //    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
    //    [urlRequest setHTTPBody:postData];
    
    //    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(error.description);
    }];
    [dataTask resume];
    NSLog(@"completed");
}

#pragma mark - draw route overlay
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView *pview = [[MKPolylineView alloc] initWithOverlay:overlay];
        pview.strokeColor = [UIColor blueColor];
        pview.lineWidth = 10;
        return pview;
    }
    return nil;
}

- (void)drawRoute
{
    MKPlacemark *source = [[MKPlacemark alloc]initWithCoordinate:self.startPin.coordinate addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil]];
    MKPlacemark *destination = [[MKPlacemark alloc]initWithCoordinate:self.destPin.coordinate addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil]];
    MKMapItem *srcMapItem = [[MKMapItem alloc] initWithPlacemark:source];
    MKMapItem *destMapItem = [[MKMapItem alloc] initWithPlacemark:destination];
    [srcMapItem setName:@"Collab"];
    [destMapItem setName:@"Delta"];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource: srcMapItem];
    [request setDestination: destMapItem];
    [request setTransportType:MKDirectionsTransportTypeWalking];
    
    MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        NSLog(@"response = %@", response);
        NSArray *arrayRoutes = [response routes];
        [arrayRoutes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MKRoute *route = obj;
            MKPolyline *line = [route polyline];
            [self.mapView addOverlay:line];
            NSLog(@"Route Name: %@", route.name);
            NSLog(@"Total Distance :%f", route.distance);
            NSArray *steps = [route steps];
            NSLog(@"Total steps: %d", [steps count]);
            [steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSLog(@"Route instruction : %@", [obj instructions]);
                NSLog(@"Route Distance: %f", [obj distance]);
            }];
        }];
    }];
}

- (void)appUsageLogging: (NSString *)activity {
    PFObject *usage = [PFObject objectWithClassName:@"UsageLog"];
    usage[@"username"] = [MyUser currentUser].username;
    usage[@"userid"] = [MyUser currentUser].objectId;
    usage[@"activity"] = activity;
    [usage saveInBackground];
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
