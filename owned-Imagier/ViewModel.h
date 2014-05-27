//
//  MyViewModel.h
//  owned-Imagier
//
//  Created by Huy on 5/24/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageViewModel.h"

@interface ViewModel : NSObject

@property (nonatomic) int currentImageIndex;
@property (nonatomic, weak) ImageViewModel *currentImageViewModel;
@property (nonatomic, readonly) NSUInteger imageCount;

@property (nonatomic) CGFloat hZoom;
@property (nonatomic) CGFloat vZoom;
@property (nonatomic) float hStretch;
@property (nonatomic) float vStretch;

@end
