//
//  ImageModel.h
//  owned-Imagier
//
//  Created by Huy on 5/26/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageViewModel : NSObject

@property (nonatomic, strong) NSString *filename;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic) CGFloat hZoom;
@property (nonatomic) CGFloat vZoom;
@property (nonatomic) float hStretch;
@property (nonatomic) float vStretch;

- (ImageViewModel *)initWithFilename:(NSString *)filename;
- (void)activate;
- (void)deactivate;

@end
