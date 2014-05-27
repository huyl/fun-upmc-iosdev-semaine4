//
//  MyViewModel.m
//  owned-Imagier
//
//  Created by Huy on 5/24/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import "ViewModel.h"


@interface ViewModel ()
@property (nonatomic, strong) NSMutableArray* imageViewModels;

@property (nonatomic, strong) RACSubject *hZoomSubject;
@property (nonatomic, strong) RACSubject *vZoomSubject;
@property (nonatomic, strong) RACSubject *hStretchSubject;
@property (nonatomic, strong) RACSubject *vStretchSubject;
@end


@implementation ViewModel

- (ViewModel*)init
{
    self = [super init];
    if (self) {
        _imageViewModels = [[NSMutableArray alloc] init];
        _currentImageIndex = -1;
        
        for (int i = 0; i < kNumImages; i++) {
            [self.imageViewModels addObject:[[ImageViewModel alloc] initWithFilename:[NSString stringWithFormat:@"photo-%02d.jpg", i + 1]]];
        }
        
        [self setupRAC];
    }
    
    return self;
}

- (void)setupRAC
{
    [[RACObserve(self, currentImageIndex) skip:1] subscribeNext:^(NSNumber *index) {
        [self activateImageAtIndex:index.intValue];
    }];
    
    // Signals of signals, so that we can switch to the latest/current imageViewModel's instance variables
    self.hZoomSubject = [RACSubject subject];
    self.vZoomSubject = [RACSubject subject];
    self.hStretchSubject = [RACSubject subject];
    self.vStretchSubject = [RACSubject subject];
    RAC(self, hZoom) = [[self.hZoomSubject switchToLatest] distinctUntilChanged];
    RAC(self, vZoom) = [[self.vZoomSubject switchToLatest] distinctUntilChanged];
    RAC(self, hStretch) = [[self.vStretchSubject switchToLatest] distinctUntilChanged];
    RAC(self, vStretch) = [[self.hStretchSubject switchToLatest] distinctUntilChanged];
    
    // We want to send the signals to the right imageViewModels
    // TODO: Is there a simpler way to do this, like switchToLatest but in the other direction?
    @weakify(self);
    [[RACObserve(self, hZoom) distinctUntilChanged] subscribeNext:^(NSNumber *hZoom) {
        @strongify(self);
        if (self.currentImageViewModel) {
            NSLog(@"setting %d hzoom to: %@", self.currentImageIndex, hZoom);
            self.currentImageViewModel.hZoom = (CGFloat)hZoom.floatValue;
            NSLog(@"for %d, new hzoom is: %f", self.currentImageIndex, self.currentImageViewModel.hZoom);
        }
    }];
    [[RACObserve(self, vZoom) distinctUntilChanged] subscribeNext:^(NSNumber *vZoom) {
        @strongify(self);
        if (self.currentImageViewModel) {
            self.currentImageViewModel.vZoom = (CGFloat)vZoom.floatValue;
        }
    }];
    [[RACObserve(self, hStretch) distinctUntilChanged] subscribeNext:^(NSNumber *hStretch) {
        @strongify(self);
        if (self.currentImageViewModel) {
            self.currentImageViewModel.hStretch = hStretch.floatValue;
        }
    }];
    [[RACObserve(self, vStretch) distinctUntilChanged] subscribeNext:^(NSNumber *vStretch) {
        @strongify(self);
        if (self.currentImageViewModel) {
            self.currentImageViewModel.hStretch = vStretch.floatValue;
        }
    }];
}

- (NSUInteger)imageCount
{
    return [self.imageViewModels count];
}

- (void)activateImageAtIndex:(int)index
{
    // We assume that we can hold two photos in memory without crashing, so we activate an image
    // before we deactive the new one
    int oldImageIndex = self.currentImageIndex;
    ImageViewModel *newImageVM = self.imageViewModels[index];
    NSLog(@"about to get current hZoom: %f", ((ImageViewModel *)self.imageViewModels[oldImageIndex]).hZoom);
    [newImageVM activate];
    
    if (oldImageIndex >= 0 && oldImageIndex != index) {
        [self.imageViewModels[oldImageIndex] deactivate];
    }
    
    // Update instance variables for subscribers to know
    self.currentImageViewModel = newImageVM;
    
    // Bind to new image's variables
    // TODO: how do we dispose or re-use old ones?
    [self.hZoomSubject sendNext:RACObserve(self, currentImageViewModel.hZoom)];
    [self.vZoomSubject sendNext:RACObserve(self, currentImageViewModel.vZoom)];
    [self.hStretchSubject sendNext:RACObserve(self, currentImageViewModel.hStretch)];
    [self.vStretchSubject sendNext:RACObserve(self, currentImageViewModel.vStretch)];
    
    NSLog(@"** ACTIVATED %@", self.currentImageViewModel);
    NSLog(@"current hZoom: %f", self.currentImageViewModel.hZoom);
}

@end
