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
        
        // Add parallax effect
        
        UIInterpolatingMotionEffect *verticalMotionEffect =
            [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                            type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        verticalMotionEffect.minimumRelativeValue = @(50);
        verticalMotionEffect.maximumRelativeValue = @(-50);
        
        UIInterpolatingMotionEffect *horizontalMotionEffect =
            [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                            type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        horizontalMotionEffect.minimumRelativeValue = @(50);
        horizontalMotionEffect.maximumRelativeValue = @(-50);
        
        UIMotionEffectGroup *group = [UIMotionEffectGroup new];
        group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
        [self.imageView addMotionEffect:group];
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

/*
 DESIGN OF THE ZOOMING: PINCH * SLIDER STRETCHES
 
 Alors, pour que l'utilisateur puisse aller du pinch au slider et retourner au pinch, etc., sans détruire les chosse, il faut des mathes malheureusement.
 
 Concepts
 --------
 
 Basically, you have to distinguish several notions.  First:
 
 - The Image size, which is fixed and never changes
 - The ImageView frame, which is affected by the sliders and the pinch
 - The ScrollView's frame, which only changes when rotating the device
 
 Second, there are two ways to visually change the size of an image: (1) you pinch in the scrollview, which can only be done in both dimensions *simultaneously*, and (2) you change the size of the ImageView, which can be done in the horizontal and vertical dimensions separately with the sliders.  When you *combine* these two scaling effects, you get the user's perceived zoom levels; this combination is done by *multiplication*.
 
 So that means, that these are all different:
 
 - The ScrollView's `zoomScale`, which is dictated by the pinch
 - The separate horizontal and vertical stretches of the image, which are affected by the sliders, but which are not equal numerically to the values of the sliders and labels!
 - And most importantly, the separate horizontal and vertical *zoom* that the user perceives.  These zoom levels are what limits the sliders and what are displayed on the labels.
 
 These perceptual zoom levels are not the same things as the ScrollView's `zoomScale` and the one-dimensional stretches of the image! The sliders' values do not equal the horizontal and vertical stretches.  The slider's values are not saved in variables.  It's the stretches that are stored in your image's instance variables and used in the formulas below to change the ImageView's frame.
 
 The Setup
 ---------
 
 When we first display the image, we want the entire image to be visible and scaled to fit the screen; so either the height or width of the ImageView matches the ScrollView's, without the other dimension being greater than the ScrollView's.  From the user's point of view, let's define 1x as this default perceptual zoom level of the image.  By the way, this initial scaling, once computed as described, should be saved for every image, as it is used for the formulas below.
 
 Now we define that the minimum perceptual zoom level in either dimension should be 0.25x and the maximum should be 4x.  This is the counter-intuitive part: even though the sliders affect the horizontal and vertical stretches of the ImageView, the numerical values of the sliders are not equal to the internet stretches, as you'll see below.
 
 Formula
 -------
 
 The perceptual zoom levels are equal to:
 
 hZoom = zoomScale * hStretch
 vZoom = zoomScale * vStretch
 
 Given constants:
 
 kMaxZoom = 4.0
 kMinZoom = 0.25
 
 Then, the perceptual zooms level are constrained by:
 
 kMinZoom <= min(hZoom, vZoom)
 max(hZoom, vZoom) <= kMaxZoom
 
 Doing some math, you then get:
 
 kMinZoom <= min(zoomScale * hStretch, zoomScale * vStretch)
 kMinZoom <= zoomScale * hStretch
 kMinZoom <= zoomScale * vStretch
 kMinZoom / hStretch <= zoomScale
 kMinZoom / vStretch <= zoomScale
 
 So:
 
 MAX(kMinZoom / hStretch, kMinZoom / vStretch) <= zoomScale
 
 Similarly with `kMaxZoom`.
 
 This is the key result.  We must change the ScrollView's `minimumZoomScale` and `maximumZoomScale` in real time, whenever the sliders change the horizontal and vertical stretches!
 
 You'll see that you can switch back and forth between the pinch and the sliders, no matter what values they are.  And it will make sense to the user.
 */
 


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
