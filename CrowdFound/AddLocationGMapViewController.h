//
//  AddLocationGMapViewController.h
//  CrowdFound
//
//  Created by Yongsung on 2/21/15.
//  Copyright (c) 2015 YK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface AddLocationGMapViewController : UIViewController
@property (strong, nonatomic) NSArray *annotations;
@property (strong, nonatomic) GMSMarker *marker;

@end
