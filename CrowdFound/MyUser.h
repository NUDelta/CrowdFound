//
//  MyUser.h
//  CrowdFound
//
//  Created by Yongsung on 11/14/14.
//  Copyright (c) 2014 YK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@interface MyUser : PFUser <PFSubclassing>
@property (retain) NSString *additional;
@property (retain) NSString *residenceHall;
@end
