//
//  MyView.h
//  owned-Imagier
//
//  Created by Huy on 5/23/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewModel.h"
#import "MyScrollView.h"


@interface MyView : UIView

@property (nonatomic, weak) UIStepper *imageStepper;
@property (nonatomic, weak) UILabel *imageLabel;

@property (nonatomic, weak) MyScrollView *scrollView;
@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, weak) UILabel *hLabel;
@property (nonatomic, weak) UILabel *vLabel;

@property (nonatomic, weak) UISlider *hSlider;
@property (nonatomic, weak) UISlider *vSlider;

- (id)initWithFrame:(CGRect)frame andViewModel:(ViewModel*)viewModel;

@end
