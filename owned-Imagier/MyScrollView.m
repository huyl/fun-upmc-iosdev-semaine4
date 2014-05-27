//
//  MyScrollView.m
//  owned-Imagier
//
//  Created by Huy on 5/25/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import "MyScrollView.h"

const CGFloat kMaxZoom = 4.0;
const CGFloat kMinZoom = 0.25;

@interface MyScrollView()<UIScrollViewDelegate>
@property (nonatomic) BOOL initialized;
@property (nonatomic, weak) UIImageView* imageView;
@property (nonatomic, weak) ViewModel* viewModel;
@property (nonatomic) float initialScale;

@property (nonatomic, strong) RACSignal *zoomSignal;
@end


@implementation MyScrollView

- (id)initWithImageView:(UIImageView*)imageView andViewModel:(ViewModel*)viewModel
{
    self = [self init];
    if (self) {
        self.imageView = imageView;
        self.viewModel = viewModel;
        self.initialized = NO;
        self.minimumZoomScale = kMinZoom;
        self.maximumZoomScale = kMaxZoom;
    }
    return self;
}

- (void)imageViewModelWasUpdated:(ImageViewModel *)imageViewModel
{
    self.imageView.image = imageViewModel.image;
    [self setupContentFrames];
}

#pragma mark - Layout

/**
 * Initialize content size and imageView frame
 */
- (void)setupContentFrames
{
    CGSize size = self.frame.size;
    
    // We're not ready to setup anything if this ScrollView hasn't been laid out according to the constraints
    if (size.height == 0 && size.width == 0) {
        return;
    }
    
    self.initialized = YES;
    
    CGRect frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    
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
    frame.size.width = (CGFloat) frame.size.width * scale * self.viewModel.hZoom;
    frame.size.height = (CGFloat) frame.size.height * scale * self.viewModel.vZoom;
    
    self.initialScale = scale;
    
    self.imageView.frame = frame;
    self.contentSize = frame.size;
}

- (void)layoutSubviews
{
    // Initialize content size and imageView frame
    if (! self.initialized) {
        [self setupContentFrames];
    }
    
    /// Re-center image if it's too small
    
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

#pragma mark - Zooming

// kMaxZoom = 4.0
// kMinZoom = 0.25
//
// This is what should be set on the sliders and displayed on the labels:
// hZoom = zoomScale * hStretch
// kMinZoom <= min(hZoom, vZoom)
// max(hZoom, vZoom) <= kMaxZoom
//
// kMinZoom <= min(zoomScale * hStretch, zoomScale * vStretch)
// kMinZoom <= zoomScale * hStretch
// kMinZoom <= zoomScale * vStretch
// kMinZoom/hStretch <= zoomScale
// kMinZoom/vStretch <= zoomScale
// MAX(kMinZoom/hStretch, kMinZoom/vStretch) <= zoomScale
// same with kMaxZoom

- (void)hZoomTo:(float)hZoom
{
    CGRect frame = self.imageView.frame;
    frame.size.width = self.imageView.image.size.width * self.initialScale * hZoom;
    self.imageView.frame = frame;
    self.contentSize = frame.size;
    
    self.viewModel.hStretch = hZoom / self.zoomScale;
    [self recalculateZoomScaleLimits];
}

- (void)vZoomTo:(float)vZoom
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
    CGFloat min = MAX(kMinZoom / self.viewModel.hStretch, kMinZoom / self.viewModel.vStretch);
    CGFloat max = MIN(kMaxZoom / self.viewModel.hStretch, kMaxZoom / self.viewModel.vStretch);
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
    if (!self.zoomSignal) {
        self.zoomSignal = [[self rac_signalForSelector:@selector(scrollViewDidZoom:) fromProtocol:@protocol(UIScrollViewDelegate)] map:^id(RACTuple *tuple) {
            return tuple.first;
        }];
    }
    
    // Set itself as delegate for zoom events
    // This function must be called *after* `-rac_signalForSelector:` is called.
    // This is a workaround, for the problem described at http://stackoverflow.com/a/22004639/161972
    // and at https://github.com/ReactiveCocoa/ReactiveCocoa/pull/745
    self.delegate = self;
    
    return self.zoomSignal;
}


@end
