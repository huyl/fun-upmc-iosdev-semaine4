//
//  MyViewModel.h
//  owned-Imagier
//
//  Created by Huy on 5/24/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyViewModel : NSObject

@property (nonatomic, retain) UIImage *image;

@property (nonatomic) CGFloat hZoom;
@property (nonatomic) CGFloat vZoom;
@property (nonatomic) float hStretch;
@property (nonatomic) float vStretch;


@end
