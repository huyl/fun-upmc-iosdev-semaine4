//
//  MyScrollView.h
//  owned-Imagier
//
//  Created by Huy on 5/25/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewModel.h"
#import "ImageViewModel.h"

extern const CGFloat kMaxZoom;
extern const CGFloat kMinZoom;


/**
 * Subclasses UIScrollView because we need to have layoutSubviews in order to give UIImageView an initial size.
 * The problem is that we size the scrollview using constraints.  So we don't know its size until the
 * scrollview is laid out.  I can't find any hooks for the parent view, so I have to subclass UIScrollView
 * to hook into layoutSubviews.
 *
 * Also, extends UIScrollView to add a ReactiveCocoa signal for its zoom events
 * Based on https://github.com/dewind/ReactiveCocoaExample/blob/master/ReactiveCocoaExample/UISearchBar%2BRAC.m
 */
@interface MyScrollView : UIScrollView

- (id)initWithImageView:(UIImageView*)imageView andViewModel:(ViewModel*)viewModel;

- (void)imageViewModelWasUpdated:(ImageViewModel *)imageViewModel;

- (void)hZoomTo:(float)hZoom;
- (void)vZoomTo:(float)hZoom;
- (void)updateZoomValuesWithScale:(float)zoomScale;

- (RACSignal *)rac_zoomSignal;
@end
