//
//  MyViewModel.m
//  owned-Imagier
//
//  Created by Huy on 5/24/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import "MyViewModel.h"

@implementation MyViewModel

- (MyViewModel*)init
{
    self = [super init];
    if (self == nil) return nil;
    
    self.image = [UIImage imageNamed:@"photo-02.jpg"];
//    self.image = [UIImage imageNamed:@"logoImagierx58.png"];
    
    
    return self;
}

@end
