//
//  HelperMapViewController.m
//  CrowdFound
//
//  Created by Yongsung on 11/10/14.
//  Copyright (c) 2014 YK. All rights reserved.
//

#import "HelperMapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import "HelperDetailViewController.h"
#import "HelperAnnotation.h"
#import "MyUser.h"

@interface HelperMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray *annotations;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *locA;
@property (strong, nonatomic) NSString *helperLocation;
@property (strong, nonatomic) NSString *helperName;
@property (strong, nonatomic) UILocalNotification *localNotif;
@property BOOL hasNotified;
@property BOOL hasPin;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)
@end

@implementation HelperMapViewController
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate =self;
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
        [self.locationManager requestAlwaysAuthorization];
    }
    if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [self.locationManager requestWhenInUseAuthorization];
    }
//    [self.locationManager requestAlwaysAuthorization];
//    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeStandard;
    
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    
    
    CLLocationCoordinate2D center; //Ford
    center.latitude = 42.056929;
    center.longitude = -87.676519;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (center, 1000, 1000);
    [self.mapView setRegion:region animated:YES];
//    HelperAnnotation *helper = [[HelperAnnotation alloc]initWithTitle:@"helper" Location:center];
//    [self.mapView addAnnotation:helper];
    // Do any additional setup after loading the view.
    self.localNotif  = [[UILocalNotification alloc] init];
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//{
//    CLLocation *locB = newLocation;
//    PFQuery *query = [MyUser query];
//    [query getObjectInBackgroundWithId:[MyUser currentUser].objectId block:^(PFObject *object, NSError *error) {
//        object[@"additional"] = [[NSString alloc]initWithFormat:@"%f, %f", locB.coordinate.latitude, locB.coordinate.longitude];
//        [object saveInBackground];
//        NSLog(@"saved new location");
//    }];
//    if(self.locA){
//        CLLocationDistance distance = [self.locA distanceFromLocation:locB];
//        //        NSLog(@"distance is %f", distance);
//        if(distance < 300) {
//            //            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(testNotif) userInfo:nil repeats:YES];
//            //            [timer fire];
//            //            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Help find lost time" message:@"Go help find lost item" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:nil];
//            //            [alert addButtonWithTitle:@"YES"];
//            //            [alert show];
//            //            self.hasNotified = YES;
//        }
//    }
//}

//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
//{
//    CLLocation *locB = [locations lastObject];
//    PFQuery *query = [MyUser query];
//    [query getObjectInBackgroundWithId:[MyUser currentUser].objectId block:^(PFObject *object, NSError *error) {
//        object[@"additional"] = [[NSString alloc]initWithFormat:@"%f, %f", locB.coordinate.latitude, locB.coordinate.longitude];
//        [object saveInBackground];
//    }];
//    if(self.locA){
//        CLLocationDistance distance = [self.locA distanceFromLocation:locB];
//        //        NSLog(@"distance is %f", distance);
//        if(distance < 300) {
//            //            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(testNotif) userInfo:nil repeats:YES];
//            //            [timer fire];
//            //            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Help find lost time" message:@"Go help find lost item" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:nil];
//            //            [alert addButtonWithTitle:@"YES"];
//            //            [alert show];
//            //            self.hasNotified = YES;
//        }
//    }
//
//}

- (void)viewWillAppear:(BOOL)animated {

}
- (void)viewDidAppear:(BOOL)animated {
//    [self getAnnotations];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.hasPin = NO;
    if ([[self.mapView annotations] count]>0)
        [self.mapView removeAnnotations:self.mapView.annotations];
    [self getAnnotations];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getAnnotations
{
    self.spinner.hidden = FALSE;
    [self.spinner startAnimating];
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        PFQuery *query = [PFQuery queryWithClassName: @"Request"];
        self.annotations = [query findObjects];
        if ([self.annotations count]>0) {
            CLLocationCoordinate2D center;
            for (NSArray *obj in self.annotations) {
                //        NSLog(@"%@, %@",[obj valueForKeyPath:@"lat"], [obj valueForKeyPath:@"lng"]);
                CLLocationCoordinate2D center;
                center.latitude = [[obj valueForKeyPath:@"lat"] floatValue];
                center.longitude = [[obj valueForKeyPath:@"lng"] floatValue];
                
                if([[self.locationManager monitoredRegions] count]>0){
                    for(CLRegion *i in [self.locationManager monitoredRegions]){
                        if(center.latitude!=i.center.latitude && center.longitude != i.center.longitude) {
                            // this is for CrowdFound v1
                            CLCircularRegion *region = [[CLCircularRegion alloc]initWithCenter:center radius:50 identifier:[obj valueForKeyPath:@"objectId"]];
                            [self.locationManager startMonitoringForRegion: region];
                            
                            // this is for CrowdFound v2
//                            NSString *str_NW = [NSString stringWithFormat:@"%@_NorthWest",[obj valueForKeyPath:@"objectId"]];
//                            NSString *str_NE = [NSString stringWithFormat:@"%@_NorthEast",[obj valueForKeyPath:@"objectId"]];
//                            NSString *str_SE = [NSString stringWithFormat:@"%@_SouthEast",[obj valueForKeyPath:@"objectId"]];
//                            NSString *str_SW = [NSString stringWithFormat:@"%@_SouthWest",[obj valueForKeyPath:@"objectId"]];
//                            
//                            [self coordinateFromCoord:center atDistanceKm:0.05 atBearingDegrees:-45 name: str_NW]; //top left NW
//                            [self coordinateFromCoord:center atDistanceKm:0.05 atBearingDegrees:45 name: str_NE]; //top right NE
//                            [self coordinateFromCoord:center atDistanceKm:0.05 atBearingDegrees:145 name: str_SE]; //bottom right SE
//                            [self coordinateFromCoord:center atDistanceKm:0.05 atBearingDegrees:-145 name: str_SW]; //botton left SW
                        }
                    }
                } else {
                    // this is for CrowdFound v1
                    CLCircularRegion *region = [[CLCircularRegion alloc]initWithCenter:center radius:50 identifier:[obj valueForKeyPath:@"objectId"]];
                    [self.locationManager startMonitoringForRegion: region];
                    [self appUsageLogging:@"v1"];
                    //NSLog(@"finished monitoring %f, %f",center.latitude, center.longitude);
                    
                    //this is for CrowdFound v2
//                    NSString *str_NW = [NSString stringWithFormat:@"%@_NorthWest",[obj valueForKeyPath:@"objectId"]];
//                    NSString *str_NE = [NSString stringWithFormat:@"%@_NorthEast",[obj valueForKeyPath:@"objectId"]];
//                    NSString *str_SE = [NSString stringWithFormat:@"%@_SouthEast",[obj valueForKeyPath:@"objectId"]];
//                    NSString *str_SW = [NSString stringWithFormat:@"%@_SouthWest",[obj valueForKeyPath:@"objectId"]];
//                    
//                    [self coordinateFromCoord:center atDistanceKm:0.05 atBearingDegrees:-45 name: str_NW]; //top left NW
//                    [self coordinateFromCoord:center atDistanceKm:0.05 atBearingDegrees:45 name: str_NE]; //top right NE
//                    [self coordinateFromCoord:center atDistanceKm:0.05 atBearingDegrees:145 name: str_SE]; //bottom right SE
//                    [self coordinateFromCoord:center atDistanceKm:0.05 atBearingDegrees:-145 name: str_SW]; //botton left SW
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI
                    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
                    pin.coordinate = center;
                    pin.title = [obj valueForKeyPath:@"item"];
                    [self.mapView addAnnotation:pin];
                    [self.spinner stopAnimating];
                    self.spinner.hidden = TRUE;
                });
            }
        }
    });

//            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(drawAnnotations) userInfo:nil repeats:YES];
//            [timer fire];
}

- (void)coordinateFromCoord:
(CLLocationCoordinate2D)fromCoord
               atDistanceKm:(double)distanceKm
           atBearingDegrees:(double)bearingDegrees
                       name: (NSString *)name
{
    double distanceRadians = distanceKm / 6371.0;
    //6,371 = Earth's radius in km
    double bearingRadians = degreesToRadians(bearingDegrees);
    double fromLatRadians = degreesToRadians(fromCoord.latitude);
    double fromLonRadians = degreesToRadians(fromCoord.longitude);
    
    double toLatRadians = asin( sin(fromLatRadians) * cos(distanceRadians)
                               + cos(fromLatRadians) * sin(distanceRadians) * cos(bearingRadians) );
    
    double toLonRadians = fromLonRadians + atan2(sin(bearingRadians)
                                                 * sin(distanceRadians) * cos(fromLatRadians), cos(distanceRadians)
                                                 - sin(fromLatRadians) * sin(toLatRadians));
    
    // adjust toLonRadians to be in the range -180 to +180...
    toLonRadians = fmod((toLonRadians + 3*M_PI), (2*M_PI)) - M_PI;
    
    CLLocationCoordinate2D result;
    result.latitude = radiandsToDegrees(toLatRadians);
    result.longitude = radiandsToDegrees(toLonRadians);
    NSLog(@"new coordinate is %f, %f", result.latitude, result.longitude);
    [self monitorSubRegions:result radius:20 name:name];
//    [self addPinWithCenter:result Title:name];
    //    return result;
}

- (void)addPinWithCenter: (CLLocationCoordinate2D)center
                   Title: (NSString *)title
{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = center;
    annotation.title = title;
    [self.mapView addAnnotation:annotation];
    [self.mapView addAnnotation:annotation];
}

- (void)monitorSubRegions: (CLLocationCoordinate2D)center
                   radius: (float) radius
                     name: (NSString *)name{
    CLCircularRegion *region = [[CLCircularRegion alloc]initWithCenter:center radius:radius identifier: name];
    [self.locationManager startMonitoringForRegion:region];
    NSLog(@"start monitoring %@", name);
}

- (void)drawAnnotations
{
    for(id annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[HelperAnnotation class]]) {
            [self.mapView removeAnnotation:annotation];
        }
    }

    CLLocationCoordinate2D center;
    for (NSArray *obj in self.annotations) {
//        NSLog(@"%@, %@",[obj valueForKeyPath:@"lat"], [obj valueForKeyPath:@"lng"]);
        MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
        CLLocationCoordinate2D center;
        center.latitude = [[obj valueForKeyPath:@"lat"] floatValue];
        center.longitude = [[obj valueForKeyPath:@"lng"] floatValue];

        if([[self.locationManager monitoredRegions] count]>0){
            for(CLRegion *i in [self.locationManager monitoredRegions]){
                if(center.latitude!=i.center.latitude && center.longitude != i.center.longitude) {
                    CLCircularRegion *region = [[CLCircularRegion alloc]initWithCenter:center radius:30 identifier:[obj valueForKeyPath:@"objectId"]];
                    [self.locationManager startMonitoringForRegion: region];
//                    NSLog(@"finished monitoring %f, %f",i.center.latitude, i.center.longitude);
                }
            }
        } else {
            CLCircularRegion *region = [[CLCircularRegion alloc]initWithCenter:center radius:50 identifier:[obj valueForKeyPath:@"objectId"]];
            [self.locationManager startMonitoringForRegion: region];
//            NSLog(@"finished monitoring %f, %f",center.latitude, center.longitude);
        }
        
//        NSLog(@"drawing %@", [obj valueForKeyPath:@"objectId"]);
//        [self.locationManager requestStateForRegion: region];

        pin.coordinate = center;
        pin.title = [obj valueForKeyPath:@"item"];
        [self.mapView addAnnotation:pin];

//        self.locA = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
//        if([[obj valueForKeyPath:@"username"] isEqualToString:[PFUser currentUser].username] && [[obj valueForKeyPath:@"helpers"] count] > 0){
//            for(NSString *helperId in [obj valueForKeyPath:@"helpers"]){
//                NSLog(@"helper id:%@", helperId);
//                PFQuery *query = [MyUser query];
//                [query whereKey:@"objectId" equalTo: helperId];
//                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                    if(!error) {
//                        if ([objects count] > 0){
//                            self.helperLocation = ((MyUser *)objects[0]).additional;
//                            self.helperName = ((MyUser *)objects[0]).username;
//                            NSLog(@"helper location is %@", self.helperLocation);
//                            CLLocationCoordinate2D helperCenter; //Ford
//                            NSArray *items = [self.helperLocation componentsSeparatedByString:@", "];
//                            helperCenter.latitude = [items[0] floatValue];
//                            helperCenter.longitude = [items[1] floatValue];
//                            HelperAnnotation *helper = [[HelperAnnotation alloc]initWithTitle:self.helperName Location:helperCenter];
//                            [self.mapView addAnnotation:helper];
//                        }
//                    } else {
//                        NSLog(@"error!!!");
//                    }
//                }];
//            }
//        }

    }

}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // Try to dequeue an existing pin view first (code not shown).
    
    // If no pin view already exists, create a new one.
    MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                          initWithAnnotation:annotation reuseIdentifier:@"LostItemPlace"];
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    } else if ([annotation isKindOfClass:[HelperAnnotation class]]) {
        HelperAnnotation *helperLocation = (HelperAnnotation *)annotation;
        MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"HelperAnnotation"];
        if(annotationView == nil) {
            annotationView = helperLocation.annotationView;
        }
        else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    } else {
        customPinView.pinColor = MKPinAnnotationColorRed;
        customPinView.animatesDrop = NO;
        customPinView.canShowCallout = YES;
//        customPinView.image = [UIImage imageNamed:@"helper.png"];
        [customPinView setDraggable:YES];
        // Because this is an iOS app, add the detail disclosure button to display details about the annotation in another view.
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        customPinView.rightCalloutAccessoryView = rightButton;
        return customPinView;
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"HelperDetailSegue" sender:view];

}

- (void)appUsageLogging: (NSString *)activity {
    PFObject *usage = [PFObject objectWithClassName:@"UsageLog"];
    usage[@"username"] = [MyUser currentUser].username;
    usage[@"userid"] = [MyUser currentUser].objectId;
    usage[@"activity"] = activity;
    [usage saveInBackground];
}

- (void)testNotif: (NSString *)objId
{
    //this is for CrowdFound v1
//    for (NSArray *place in self.annotations){
//        NSArray *objIdParsed = [objId componentsSeparatedByString:@"_"];
//        NSLog(@"%@ and %@", objId, objIdParsed[0]);
////        if ([(NSString *)[place valueForKeyPath:@"objectId"] isEqualToString:objId]){
//        if ([(NSString *)[place valueForKeyPath:@"objectId"] isEqualToString:objIdParsed[0]]){
//            self.localNotif = [[UILocalNotification alloc] init];
//            NSDictionary *dictionary = [NSDictionary dictionaryWithObject:objId forKey:objId];
//            self.localNotif.userInfo = dictionary;
//            self.localNotif.alertBody = [NSString stringWithFormat:@"%@ lost %@, would you like to help?", [place valueForKeyPath:@"username"], [place valueForKeyPath:@"item"]];
//            self.localNotif.alertAction = @"Testing notification based on regions";
//            self.localNotif.soundName = UILocalNotificationDefaultSoundName;
//            if (self.localNotif) {
//                self.localNotif.applicationIconBadgeNumber = 1;
//                [self appUsageLogging:@"notification"];
//                [[UIApplication sharedApplication] presentLocalNotificationNow:self.localNotif];
//            }
//        }
//    }
    for (NSArray *a in self.annotations) {
        NSLog(@"===============testing %@ and %@ and %@===============", [a valueForKeyPath:@"username"], [a valueForKeyPath:@"item"], [a valueForKeyPath:@"objectId"]);
        NSString *tmp = [a valueForKeyPath:@"objectId"];
        NSArray *objIdParsed = [objId componentsSeparatedByString:@"_"];
        if ([tmp isEqualToString:objIdParsed[0]]) {
            NSDictionary *dictionary = [NSDictionary dictionaryWithObject:objIdParsed[0] forKey:objId];
            self.localNotif.userInfo = dictionary;
            self.localNotif.alertBody = [NSString stringWithFormat:@"%@ lost %@ near %@, would you like to help?", [a valueForKeyPath:@"username"], [a valueForKeyPath:@"item"], [a valueForKeyPath:@"locDetail"]];
//            self.localNotif.alertBody = [NSString stringWithFormat:@"%@ lost %@ near %@, would you like to help?", [a valueForKeyPath:@"username"], [a valueForKeyPath:@"item"], objId];
            self.localNotif.applicationIconBadgeNumber = 1;
            NSString *noti_str = [NSString stringWithFormat:@"notificatino for %@", [a valueForKeyPath:@"locDetail"]];
            [self appUsageLogging:noti_str];
            self.localNotif.soundName = UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] presentLocalNotificationNow:self.localNotif];
        }
    }
}

- (void)logCurrentLocation {
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        NSString *geoCoordinate = [NSString stringWithFormat:@"%f, %f", geoPoint.latitude, geoPoint.longitude];
        [self appUsageLogging:geoCoordinate];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if(!self.hasNotified) {
        [self testNotif:region.identifier];
        NSLog(@"entered region: %@", region.identifier);
        [self.locationManager stopMonitoringForRegion:region];
        [self appUsageLogging: region.identifier];
        [self logCurrentLocation];
//        self.hasNotified = YES;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"HelperDetailSegue"]) {
        HelperDetailViewController *hdvc = [segue destinationViewController];
//        hdvc.annotation = ((MKAnnotationView *)sender).annotation;
        for (NSArray *obj in self.annotations) {
            if(([[obj valueForKeyPath:@"lat"] floatValue] == ((MKAnnotationView *)sender).annotation.coordinate.latitude)
               && (([[obj valueForKeyPath:@"lng"] floatValue] == ((MKAnnotationView *)sender).annotation.coordinate.longitude))){
                hdvc.request = obj;
                break;
            }
        }
    }
}


@end
