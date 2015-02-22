//
//  HelperGoogleMapViewController.m
//  CrowdFound
//
//  Created by Yongsung on 2/21/15.
//  Copyright (c) 2015 YK. All rights reserved.
//

#import "HelperGoogleMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import "HelperDetailViewController.h"
#import "HelperAnnotation.h"
#import "MyUser.h"
#import <CoreMotion/CoreMotion.h>

@interface HelperGoogleMapViewController () <CLLocationManagerDelegate, GMSMapViewDelegate>
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
@property (nonatomic, retain) CMMotionActivityManager *motionManager;
@property (nonatomic, strong) GMSMapView *mapView;

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

@end

@implementation HelperGoogleMapViewController
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
    // Do any additional setup after loading the view.
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
    self.locationManager.distanceFilter = 50;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:42.056929
                                                            longitude:-87.676519
                                                                 zoom:16];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.view = self.mapView;
    self.mapView.delegate = self;
    
    CLLocationCoordinate2D center; //Ford
    center.latitude = 42.056929;
    center.longitude = -87.676519;

    //    HelperAnnotation *helper = [[HelperAnnotation alloc]initWithTitle:@"helper" Location:center];
    //    [self.mapView addAnnotation:helper];
    // Do any additional setup after loading the view.
    self.localNotif  = [[UILocalNotification alloc] init];
    
    self.motionManager = [[CMMotionActivityManager alloc]init];
}

- (void)viewDidAppear:(BOOL)animated {
    //    [self getAnnotations];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.hasPin = NO;
    [self.mapView clear];
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
                            //                            CLCircularRegion *region = [[CLCircularRegion alloc]initWithCenter:center radius:50 identifier:[obj valueForKeyPath:@"objectId"]];
                            //                            [self.locationManager startMonitoringForRegion: region];
                            
                            // this is for CrowdFound v2
                            NSString *str_NW = [NSString stringWithFormat:@"%@_NorthWest",[obj valueForKeyPath:@"objectId"]];
                            NSString *str_NE = [NSString stringWithFormat:@"%@_NorthEast",[obj valueForKeyPath:@"objectId"]];
                            NSString *str_SE = [NSString stringWithFormat:@"%@_SouthEast",[obj valueForKeyPath:@"objectId"]];
                            NSString *str_SW = [NSString stringWithFormat:@"%@_SouthWest",[obj valueForKeyPath:@"objectId"]];
                            
                            [self coordinateFromCoord:center atDistanceKm:0.05 atBearingDegrees:-45 name: str_NW]; //top left NW
                            [self coordinateFromCoord:center atDistanceKm:0.05 atBearingDegrees:45 name: str_NE]; //top right NE
                            [self coordinateFromCoord:center atDistanceKm:0.05 atBearingDegrees:145 name: str_SE]; //bottom right SE
                            [self coordinateFromCoord:center atDistanceKm:0.05 atBearingDegrees:-145 name: str_SW]; //botton left SW
                        }
                    }
                } else {
                    // this is for CrowdFound v1
                    //                    CLCircularRegion *region = [[CLCircularRegion alloc]initWithCenter:center radius:50 identifier:[obj valueForKeyPath:@"objectId"]];
                    //                    [self.locationManager startMonitoringForRegion: region];
                    //                    [self appUsageLogging:@"v1"];
                    //NSLog(@"finished monitoring %f, %f",center.latitude, center.longitude);
                    
                    //this is for CrowdFound v2
                    NSString *str_NW = [NSString stringWithFormat:@"%@_NorthWest",[obj valueForKeyPath:@"objectId"]];
                    NSString *str_NE = [NSString stringWithFormat:@"%@_NorthEast",[obj valueForKeyPath:@"objectId"]];
                    NSString *str_SE = [NSString stringWithFormat:@"%@_SouthEast",[obj valueForKeyPath:@"objectId"]];
                    NSString *str_SW = [NSString stringWithFormat:@"%@_SouthWest",[obj valueForKeyPath:@"objectId"]];
                    
                    [self coordinateFromCoord:center atDistanceKm:0.05 atBearingDegrees:-45 name: str_NW]; //top left NW
                    [self coordinateFromCoord:center atDistanceKm:0.05 atBearingDegrees:45 name: str_NE]; //top right NE
                    [self coordinateFromCoord:center atDistanceKm:0.05 atBearingDegrees:145 name: str_SE]; //bottom right SE
                    [self coordinateFromCoord:center atDistanceKm:0.05 atBearingDegrees:-145 name: str_SW]; //botton left SW
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI
                    [self addPinWithCenter:center Title:[obj valueForKeyPath:@"item"]];
                    [self.spinner stopAnimating];
                    self.spinner.hidden = TRUE;
                });
            }
        }
    });
    
    //            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(drawAnnotations) userInfo:nil repeats:YES];
    //            [timer fire];
}

#pragma mark - Google Map View
- (void)addPinWithCenter: (CLLocationCoordinate2D)center
                   Title: (NSString *)title
{
    GMSMarker *marker = [GMSMarker markerWithPosition:center];
    marker.title = title;
    marker.map = self.mapView;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    NSLog(@"clicked! marker");
    NSLog(@"marker position: %f,%f",marker.position.latitude, marker.position.longitude);
    [self performSegueWithIdentifier:@"HelperDetailSegue" sender:marker];
}

#pragma mark - Location Manager

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

- (void)monitorSubRegions: (CLLocationCoordinate2D)center
                   radius: (float) radius
                     name: (NSString *)name{
    CLCircularRegion *region = [[CLCircularRegion alloc]initWithCenter:center radius:radius identifier: name];
    [self.locationManager startMonitoringForRegion:region];
    NSLog(@"start monitoring %@", name);
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self getAnnotations];
}

- (void)detectMotion: (NSString *)identifier{
    if([CMMotionActivityManager isActivityAvailable]) {
        [self.motionManager startActivityUpdatesToQueue:[[NSOperationQueue alloc]init] withHandler:^(CMMotionActivity *activity) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (activity.walking || activity.running) {
                    [self testNotif:identifier];
                }
            });
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if(!self.hasNotified) {
        NSLog(@"entered region: %@", region.identifier);
        [self.locationManager stopMonitoringForRegion:region];
        [self appUsageLogging: region.identifier];
        [self logCurrentLocation];
        [self detectMotion: region.identifier];
        //        self.hasNotified = YES;
    }
}

#pragma mark - Notification
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


- (void)triggerLocalNotification: (NSString *)activity {
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = [NSString stringWithFormat:@"You are %@", activity];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber]+1;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

#pragma mark - Logging

- (void)logCurrentLocation {
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        NSString *geoCoordinate = [NSString stringWithFormat:@"%f, %f", geoPoint.latitude, geoPoint.longitude];
        [self appUsageLogging:geoCoordinate];
    }];
}

- (void)appUsageLogging: (NSString *)activity {
    PFObject *usage = [PFObject objectWithClassName:@"UsageLog"];
    usage[@"username"] = [MyUser currentUser].username;
    usage[@"userid"] = [MyUser currentUser].objectId;
    usage[@"activity"] = activity;
    [usage saveInBackground];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"HelperDetailSegue"]) {
        HelperDetailViewController *hdvc = [segue destinationViewController];
        for (NSArray *obj in self.annotations) {
            if(([[obj valueForKeyPath:@"lat"] floatValue] == ((GMSMarker *)sender).position.latitude)
               && (([[obj valueForKeyPath:@"lng"] floatValue] == ((GMSMarker *)sender).position.longitude))){
                hdvc.request = obj;
                break;
            }
        }
    }
}


@end
