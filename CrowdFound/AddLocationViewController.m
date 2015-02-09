//
//  AddLocationViewController.m
//  CrowdFound
//
//  Created by Yongsung on 11/13/14.
//  Copyright (c) 2014 YK. All rights reserved.
//

#import "AddLocationViewController.h"
#import <MapKit/MapKit.h>
#import "RequestDetailViewController.h"

@interface AddLocationViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation AddLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsUserLocation = YES;
    
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    
    
    CLLocationCoordinate2D center; //Ford
    center.latitude = 42.056929;
    center.longitude = -87.676519;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (center, 1000, 1000);
    [self.mapView setRegion:region animated:YES];

    [self dropPins];

    // Do any additional setup after loading the view.
}

- (void)dropPins
{
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.1; //user needs to press for half a second.
    [self.mapView addGestureRecognizer:lpgr];
}

-(void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if( gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.title = @"Lost item place";
    point.coordinate = touchMapCoordinate;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:point];
    self.annotations = self.mapView.annotations;
    //    [self.locationArray addObject:<#(id)#>]
    //    NSLog(@"%@", touchMapCoordinate);
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // Try to dequeue an existing pin view first (code not shown).
    
    // If no pin view already exists, create a new one.
    MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                          initWithAnnotation:annotation reuseIdentifier:@"Lost Item Place"];
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    } else {
        customPinView.pinColor = MKPinAnnotationColorRed;
        customPinView.animatesDrop = YES;
        customPinView.canShowCallout = YES;
        [customPinView setDraggable:YES];
        // Because this is an iOS app, add the detail disclosure button to display details about the annotation in another view.
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        customPinView.rightCalloutAccessoryView = rightButton;
        customPinView.userInteractionEnabled = YES;
        return customPinView;
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
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue
//                 sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"completeAddLocation"]) {
//        RequestDetailViewController *rdvc = [segue destinationViewController];
//        rdvc.annotations = self.mapView.annotations;
//    }
//}

@end
