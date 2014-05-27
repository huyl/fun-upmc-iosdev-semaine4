//
//  MyView.m
//  owned-Imagier
//
//  Created by Huy on 5/23/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import "MyView.h"
#import "MyScrollView.h"
#import "Masonry.h"

@interface MyView ()
@property (nonatomic, weak) MyViewModel *viewModel;
@end

@implementation MyView

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame andViewModel:(MyViewModel*)viewModel
{
    self = [self initWithFrame:frame];
    if (self == nil) return nil;
    
    self.viewModel = viewModel;
    
    UIStepper *imageStepper = [[UIStepper alloc] init];
//    [self.imageStepper addTarget:self action:@selector(imageStepperDidChange:)
//                forControlEvents:UIControlEventValueChanged];
    self.imageStepper = imageStepper;
    [self addSubview:self.imageStepper];
    
    UILabel *imageLabel = [[UILabel alloc] init];
    self.imageLabel = imageLabel;
    self.imageLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.imageLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.viewModel.image];
    self.imageView = imageView;
    self.imageView.backgroundColor = [UIColor blackColor];
    NSLog(@"Original ImageView frame: %@", NSStringFromCGRect(self.imageView.frame));
    
    MyScrollView *scrollView = [[MyScrollView alloc] initWithImageView:self.imageView andViewModel:self.viewModel];
    self.scrollView = scrollView;
    self.scrollView.backgroundColor = [UIColor darkGrayColor];
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    
    UILabel *hLabel = [[UILabel alloc] init];
    self.hLabel = hLabel;
    self.hLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.hLabel];
    
    UISlider *hSlider = [[UISlider alloc] init];
    self.hSlider = hSlider;
    self.hSlider.minimumValue = MIN_ZOOM;
    self.hSlider.maximumValue = MAX_ZOOM;
    [self addSubview:self.hSlider];

    UILabel *vLabel = [[UILabel alloc] init];
    self.vLabel = vLabel;
    self.vLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.vLabel];
    
    UISlider *vSlider = [[UISlider alloc] init];
    self.vSlider = vSlider;
    self.vSlider.minimumValue = MIN_ZOOM;
    self.vSlider.maximumValue = MAX_ZOOM;
    [self addSubview:self.vSlider];
    
    
    [self resetToDefaults];
    
    
    return self;
}

#pragma mark -

- (void)updateConstraints
{
    NSLog(@"updateConstraints");
    
    UIView *superview = self;
    
    // Config
    UIEdgeInsets padding = UIEdgeInsetsMake(32, 10, 10, 10);
    UIOffset internal = UIOffsetMake(10, 10);
    NSNumber *sliderHeight = @29;
    NSNumber *labelHeight = @21;
    CGFloat labelOffset = 20;
    
    
    [self.imageStepper mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superview).with.offset(padding.top);
        make.left.equalTo(superview).with.offset(padding.left);
    }];
    
    [self.imageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superview).with.offset(padding.top);
        make.right.greaterThanOrEqualTo(superview).with.offset(-padding.right);
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageStepper.mas_bottom).with.offset(internal.vertical);
        make.left.equalTo(superview).with.offset(padding.left);
        make.bottom.equalTo(self.hLabel.mas_top).with.offset(-internal.vertical);
        make.right.equalTo(superview).with.offset(-padding.right);
    }];
    
    [self.hLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(superview).with.offset(padding.left + labelOffset);
        make.bottom.equalTo(self.hSlider.mas_top).with.offset(-internal.vertical);
        make.height.equalTo(labelHeight);
    }];
    
    [self.hSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(superview).with.offset(padding.left);
        make.bottom.equalTo(self.vLabel.mas_top).with.offset(-internal.vertical);
        make.right.equalTo(superview).with.offset(-padding.right);
        make.height.equalTo(sliderHeight);
    }];
    
    [self.vLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(superview).with.offset(padding.left + labelOffset);
        make.bottom.equalTo(self.vSlider.mas_top).with.offset(-internal.vertical);
        make.height.equalTo(labelHeight);
    }];
    
    [self.vSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(superview).with.offset(padding.left);
        make.bottom.equalTo(superview).with.offset(-padding.bottom);
        make.right.equalTo(superview).with.offset(-padding.right);
        make.height.equalTo(sliderHeight);
    }];
    
    [super updateConstraints];
}

- (void)resetToDefaults
{
    self.viewModel.hZoom = 1.0;
    self.viewModel.vZoom = 1.0;
    self.viewModel.hStretch = 1.0;
    self.viewModel.vStretch = 1.0;
}

#pragma mark -

@end
