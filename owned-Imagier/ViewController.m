//
//  ViewController.m
//  owned-Imagier
//
//  Created by Huy on 5/23/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import "ViewController.h"
#import "MyView.h"
#import "ViewModel.h"

@interface ViewController ()

@property (nonatomic, strong) MyView *mainView;
@property (nonatomic, strong) ViewModel *viewModel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Instantiate ViewModel
    _viewModel = [[ViewModel alloc] init];

    // Instantiate main View
    _mainView = [[MyView alloc] initWithFrame:[[UIScreen mainScreen] bounds] andViewModel:self.viewModel];
    self.mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mainView];
    
    [self setupRAC];
}

- (void)setupRAC
{
    @weakify(self);
    
    // ScrollView reacts to changing current image in ViewModel
    // NOTE: we skip 1 because the first imageViewModel is nil
    [[RACObserve(self, viewModel.currentImageViewModel) skip:1] subscribeNext:^(ImageViewModel *imageViewModel) {
        [self.mainView.scrollView imageViewModelWasUpdated:imageViewModel];
    }];
    // Label reacts to changing current image in ViewModel
    // NOTE: we skip 1 because the first imageViewModel is nil
    RAC(self.mainView.imageLabel, text) = RACObserve(self, viewModel.currentImageViewModel.filename);
    
    // ViewModel current image reacts to changes in Stepper
    RAC(self.viewModel, currentImageIndex) = RACObserve(self, mainView.imageStepper.value);
    // Stepper reacts to ViewModel image count (should only happen once)
    RAC(self.mainView.imageStepper, maximumValue) =
        [RACObserve(self, viewModel.imageCount) map:^NSNumber *(NSNumber *i) {
            return @(i.intValue - 1);
        }];
    
    // Set up bidirectional binding between viewModel and hSlider value
    // See https://github.com/ReactiveCocoa/ReactiveCocoa/issues/1178
    RACChannelTerminal *hSliderFTerminal = RACChannelTo(self, viewModel.hZoom);
    RACChannelTerminal *hSliderLTerminal = [self.mainView.hSlider rac_newValueChannelWithNilValue:@0];
    [hSliderFTerminal subscribe:hSliderLTerminal];
    [hSliderLTerminal subscribe:hSliderFTerminal];

    // Set up bidirectional binding between viewModel and vSlider value
    RACChannelTerminal *vSliderFTerminal = RACChannelTo(self, viewModel.vZoom);
    RACChannelTerminal *vSliderLTerminal = [self.mainView.vSlider rac_newValueChannelWithNilValue:@0];
    [vSliderFTerminal subscribe:vSliderLTerminal];
    [vSliderLTerminal subscribe:vSliderFTerminal];
    
    // Labels react to changing zoom levels from viewModel
    RAC(self.mainView.hLabel, text) = [RACObserve(self, viewModel.hZoom) map:^(NSNumber *hZoom) {
        return [NSString stringWithFormat:@"Largeur : %0.2gx", hZoom.floatValue];
    }];
    RAC(self.mainView.vLabel, text) = [RACObserve(self, viewModel.vZoom) map:^(NSNumber *vZoom) {
        return [NSString stringWithFormat:@"Hauteur : %0.2gx", vZoom.floatValue];
    }];
    // Scrollview reacts to changing zoom levels from viewModel
    [[RACObserve(self, viewModel.hZoom) skip:1] subscribeNext:^(NSNumber *hZoom) {
        @strongify(self);
        [self.mainView.scrollView hZoomTo:hZoom.floatValue];
    }];
    [[RACObserve(self, viewModel.vZoom) skip:1] subscribeNext:^(NSNumber *vZoom) {
        @strongify(self);
        [self.mainView.scrollView vZoomTo:vZoom.floatValue];
    }];
    
    // ViewModel reacts to changing zoom levels from UIScrollView
    [self.mainView.scrollView.rac_zoomSignal subscribeNext:^(UIView* view) {
        @strongify(self);
        [self.mainView.scrollView updateZoomValuesWithScale:self.mainView.scrollView.zoomScale];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
