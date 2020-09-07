//
//  FadePresentingViewController.m
//  ColorfulSchool
//
//  Created by 李宗良 on 2020/8/12.
//  Copyright © 2020 Colorful Any Door. All rights reserved.
//


@interface FadePresentation : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) BOOL presenting;
@property (nonatomic, strong) UIViewController *fromVC;
@property (nonatomic, strong) UIViewController *toVC;
@property (nonatomic, nullable, copy) void(^animationBlock)(BOOL isPresenting);

@end

@implementation FadePresentation

- (instancetype)initWithFromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC animationBlock:(void(^ _Nullable)(BOOL))animationBlock {
    self = [super init];
    if (self) {
        _presenting = YES;
        _fromVC = fromVC;
        _toVC = toVC;
        _animationBlock = animationBlock;
    }
    return self;
}

#pragma mark UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

#pragma mark UIViewControllerTransitioningDelegate

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = transitionContext.containerView;
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    if (_presenting) {
        [containerView addSubview:_toVC.view];
        _toVC.view.alpha = 0;
        [UIView animateWithDuration:duration animations:^{
            self.toVC.view.alpha = 1;
            if (self.animationBlock != nil) {
                self.animationBlock(self.presenting);
            }
        } completion:^(BOOL finished) {
            if (finished) {
                self.toVC.view.alpha = 1;
                [transitionContext completeTransition:YES];
            }
        }];
    } else {
        [UIView animateWithDuration:duration animations:^{
            self.fromVC.view.alpha = 0;
            if (self.animationBlock != nil) {
                self.animationBlock(self.presenting);
            }
        } completion:^(BOOL finished) {
            if (finished) {
                [transitionContext completeTransition:YES];
            }
        }];
    }
}

@end

#pragma mark -

#import "FadePresentationViewController.h"

@interface FadePresentationViewController () <UIViewControllerTransitioningDelegate>

@end

@implementation FadePresentationViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self fadePresentationSetup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self fadePresentationSetup];
    }
    return self;
}

- (void)fadePresentationSetup {
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
    self.definesPresentationContext = YES;
    self.dismissByTappingBlank = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
    
    UIView *blankView = [[UIView alloc] init];
    blankView.backgroundColor = [UIColor clearColor];
    blankView.userInteractionEnabled = YES;
    [blankView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappingBlank:)]];
    [self.view addSubview:blankView];
    blankView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [blankView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [blankView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [blankView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [blankView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (void)tappingBlank:(id)sender {
    if (_dismissByTappingBlank) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[FadePresentation alloc] initWithFromVC:presenting toVC:presented animationBlock:_presentingBlock];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if (self.presentingViewController) {
        FadePresentation *animatedTransitioning = [[FadePresentation alloc] initWithFromVC:self toVC:self.presentingViewController animationBlock:_presentingBlock];
        animatedTransitioning.presenting = NO;
        return animatedTransitioning;
    }
    return nil;
}

@end
