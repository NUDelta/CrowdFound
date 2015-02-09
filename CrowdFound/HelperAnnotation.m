//
//  HelperAnnotation.m
//  CrowdFound
//
//  Created by Yongsung on 11/14/14.
//  Copyright (c) 2014 YK. All rights reserved.
//

#import "HelperAnnotation.h"

@implementation HelperAnnotation

-(id)initWithTitle:(NSString *)newTitle Location:(CLLocationCoordinate2D)location
{
    self = [super init];
    if(self)
    {
        _title = newTitle;
        _coordinate = location;
    }
    return self;
}

-(MKAnnotationView *)annotationView
{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:self reuseIdentifier:@"HelperAnnotation"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.image = [UIImage imageNamed:@"helper.png"];
//    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return annotationView;
}
@end
