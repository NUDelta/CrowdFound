//
//  RequestDetailViewController.h
//  CrowdFound
//
//  Created by Yongsung on 11/10/14.
//  Copyright (c) 2014 YK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface RequestDetailViewController : UIViewController
@property (strong, nonatomic) NSArray *annotations;
@property (strong, nonatomic) GMSMarker *marker;

@end
