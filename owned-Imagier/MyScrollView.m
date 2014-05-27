//
//  MyScrollView.m
//  owned-Imagier
//
//  Created by Huy on 5/25/14.
//  Copyright (c) 2014 huy. All rights reserved.
//
// MAX_ZOOM = 4.0
// MIN_ZOOM = 0.25
//
// This is what should be set on the sliders and displayed on the labels:
// hZoom = zoomScale * hStretch
// MIN_ZOOM <= min(hZoom, vZoom)
// max(hZoom, vZoom) <= MAX_ZOOM
//
// MIN_ZOOM <= min(zoomScale * hStretch, zoomScale * vStretch)
// MIN_ZOOM <= zoomScale * hStretch
// MIN_ZOOM <= zoomScale * vStretch
// MIN_ZOOM/hStretch <= zoomScale
// MIN_ZOOM/vStretch <= zoomScale
// MAX(MIN_ZOOM/hStretch, MIN_ZOOM/vStretch) <= zoomScale
// same with MAX_ZOOM

#import "MyScrollView.h"
#import <objc/objc-runtime.h>

@interface MyScrollView()<UIScrollViewDelegate>
@property (nonatomic) BOOL initialized;
@property (nonatomic, weak) UIImageView* imageView;
@property (nonatomic, weak) MyViewModel* viewModel;
@property (nonatomic) float initialScale;
@end


@implementation MyScrollView

- (id)initWithImageView:(UIImageView*)imageView andViewModel:(MyViewModel*)viewModel
{
    self = [self init];
    if (self) {
        self.imageView = imageView;
        self.viewModel = viewModel;
        self.initialized = NO;
        self.minimumZoomScale = MIN_ZOOM;
        self.maximumZoomScale = MAX_ZOOM;
    }
    return self;
}

/**
 * Initialize content size and imageView frame
 */
- (void)setupContentFrames
{
    self.initialized = YES;
    
    CGSize size = self.frame.size;
    CGRect frame = self.imageView.frame;
    
    // Scale image to fit, preserving aspect ratio
    float scale = 1.0;
    if (frame.size.width > size.width) {
        scale = (CGFloat)size.width / frame.size.width;
    }
    if (frame.size.height > size.height) {
        float vScale = (CGFloat)size.height / frame.size.height;
        if (vScale < scale) {
            scale = vScale;
        }
    }
    frame.size.width = (CGFloat) frame.size.width * scale;
    frame.size.height = (CGFloat) frame.size.height * scale;
    
    self.initialScale = scale;
    
    frame.origin.x = 0;
    frame.origin.y = 0;
    self.imageView.frame = frame;
    self.contentSize = frame.size;
}

- (void)layoutSubviews
{
    // Initialize content size and imageView frame
    if (! self.initialized) {
        [self setupContentFrames];
    }
    
    // Re-center image if it's too small
    
    // FIXME: probably should just start from the image size rather than the imageView.frame
    CGSize size = self.frame.size;
    CGRect frame = self.imageView.frame;
    
    // Center for dimension(s) where scaled image is smaller
    if (frame.size.width < size.width) {
        frame.origin.x = (size.width - frame.size.width) / 2;
    } else {
        frame.origin.x = 0;
    }
    if (frame.size.height < size.height) {
        frame.origin.y = (size.height - frame.size.height) / 2;
    } else {
        frame.origin.y = 0;
    }
    self.imageView.frame = frame;
}

- (void)stretchHorizontallyTo:(float)hZoom
{
    CGRect frame = self.imageView.frame;
    frame.size.width = self.imageView.image.size.width * self.initialScale * hZoom;
    self.imageView.frame = frame;
    self.contentSize = frame.size;
    
    self.viewModel.hStretch = hZoom / self.zoomScale;
    [self recalculateZoomScaleLimits];
}

- (void)stretchVerticallyTo:(float)vZoom
{
    CGRect frame = self.imageView.frame;
    frame.size.height = self.imageView.image.size.height * self.initialScale * vZoom;
    self.imageView.frame = frame;
    self.contentSize = frame.size;
    
    self.viewModel.vStretch = vZoom / self.zoomScale;
    [self recalculateZoomScaleLimits];
}

- (void)recalculateZoomScaleLimits
{
    CGFloat min = MAX(MIN_ZOOM / self.viewModel.hStretch, MIN_ZOOM / self.viewModel.vStretch);
    CGFloat max = MIN(MAX_ZOOM / self.viewModel.hStretch, MAX_ZOOM / self.viewModel.vStretch);
    if (min > max) {
        min = max;
    }
    
    self.maximumZoomScale = max;
    self.minimumZoomScale = min;
    /*
    NSLog(@"zoomScale: %.2f <= %.2f <= %.2f", self.minimumZoomScale, self.zoomScale, self.maximumZoomScale);
    NSLog(@"stretch: %.2f x %.2f", self.viewModel.hStretch, self.viewModel.vStretch);
    NSLog(@"zoom: %.2f x %.2f", self.viewModel.hZoom, self.viewModel.vZoom);
    NSLog(@"imageView.size: %@", NSStringFromCGSize(self.imageView.frame.size));
    NSLog(@"contentSize: %@", NSStringFromCGSize(self.contentSize));
    */
}

- (void)updateZoomValuesWithScale:(float)zoomScale
{
    self.viewModel.hZoom = zoomScale * self.viewModel.hStretch;
    self.viewModel.vZoom = zoomScale * self.viewModel.vStretch;
}

#pragma mark - UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
}

- (RACSignal *)rac_zoomSignal {
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    if (signal != nil) return signal;
    signal = [[self rac_signalForSelector:@selector(scrollViewDidZoom:) fromProtocol:@protocol(UIScrollViewDelegate)] map:^id(RACTuple *tuple) {
        return tuple.first;
    }];
    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Set itself as delegate for zoom events
    // This function must be called *after* `-rac_signalForSelector:` is called.
    // This is a workaround, for the problem described at http://stackoverflow.com/a/22004639/161972
    self.delegate = self;
    
    return signal;
}


@end
