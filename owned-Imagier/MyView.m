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
@property (nonatomic, weak) ViewModel *viewModel;
@property (nonatomic, strong) MASConstraint *imageLabelCenterConstraint;
@end

@implementation MyView

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame andViewModel:(ViewModel*)viewModel
{
    self = [self initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fond-1024x1024.jpg"]];
    
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
    
    UIImageView *imageView = [[UIImageView alloc] init];
    self.imageView = imageView;
    
    MyScrollView *scrollView = [[MyScrollView alloc] initWithImageView:self.imageView andViewModel:self.viewModel];
    self.scrollView = scrollView;
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    
    UILabel *hLabel = [[UILabel alloc] init];
    self.hLabel = hLabel;
    self.hLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.hLabel];
    
    UISlider *hSlider = [[UISlider alloc] init];
    self.hSlider = hSlider;
    self.hSlider.minimumValue = kMinZoom;
    self.hSlider.maximumValue = kMaxZoom;
    [self addSubview:self.hSlider];

    UILabel *vLabel = [[UILabel alloc] init];
    self.vLabel = vLabel;
    self.vLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.vLabel];
    
    UISlider *vSlider = [[UISlider alloc] init];
    self.vSlider = vSlider;
    self.vSlider.minimumValue = kMinZoom;
    self.vSlider.maximumValue = kMaxZoom;
    [self addSubview:self.vSlider];
    
    [self setupConstraints];
    
    return self;
}

#pragma mark -

- (void)setupConstraints
{
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
}

- (void)updateConstraints
{
    if (self.bounds.size.width >= 480) {
        [self.imageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            self.imageLabelCenterConstraint = make.centerX.equalTo(self);
        }];
    } else if (self.imageLabelCenterConstraint) {
        [self.imageLabelCenterConstraint uninstall];
        self.imageLabelCenterConstraint = nil;
    }
    
    [super updateConstraints];
}

@end
