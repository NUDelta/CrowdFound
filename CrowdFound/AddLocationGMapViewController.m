//
//  AddLocationGMapViewController.m
//  CrowdFound
//
//  Created by Yongsung on 2/21/15.
//  Copyright (c) 2015 YK. All rights reserved.
//

#import "AddLocationGMapViewController.h"
#import "RequestDetailViewController.h"

@interface AddLocationGMapViewController () <CLLocationManagerDelegate, GMSMapViewDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation AddLocationGMapViewController

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
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:42.056929
                                                            longitude:-87.676519
                                                                 zoom:17];
    
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled = YES;
    self.mapView.delegate = self;
    self.mapView.settings.myLocationButton = YES;

    [self.locationManager startUpdatingLocation];
    
    CLLocationCoordinate2D center; //Ford
    center.latitude = 42.056929;
    center.longitude = -87.676519;
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self.mapView clear];
    GMSMarker *locationMarker = [GMSMarker markerWithPosition:coordinate];
    locationMarker.map = self.mapView;
    self.marker = locationMarker;
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
