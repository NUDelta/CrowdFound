//
//  HelperAnnotation.h
//  CrowdFound
//
//  Created by Yongsung on 11/14/14.
//  Copyright (c) 2014 YK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface HelperAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;

-(id)initWithTitle:(NSString *)newTitle Location:(CLLocationCoordinate2D)location;
-(MKAnnotationView *)annotationView;

@end
