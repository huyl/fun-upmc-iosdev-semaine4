//
//  ImageModel.m
//  owned-Imagier
//
//  Created by Huy on 5/26/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import "ImageViewModel.h"

@implementation ImageViewModel

- (ImageViewModel *)initWithFilename:(NSString *)filename
{
    self = [super init];
    if (self) {
        _filename = filename;
        
        _hZoom = 1.0;
        _vZoom = 1.0;
        _hStretch = 1.0;
        _vStretch = 1.0;
    }
    
    return self;
}

- (void)activate
{
    if (!self.image) {
        self.image = [UIImage imageNamed:self.filename];
    } else {
        NSLog(@"reusing");
    }
    NSLog(@"my hzoom %f", self.hZoom);
}

- (void)deactivate
{
    // To reduce memory usage, we unload the image
    self.image = nil;
}

@end
