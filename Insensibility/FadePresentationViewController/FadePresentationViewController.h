//
//  FadePresentingViewController.h
//  ColorfulSchool
//
//  Created by 李宗良 on 2020/8/12.
//  Copyright © 2020 Colorful Any Door. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FadePresentationViewController : UIViewController

/// 在 FadePresentationViewController 被 present 或 dismiss 的过程中，会调用此方法。
/// 在这个方法中，只需调整内部元素的位置。
@property (nonatomic, nullable, copy) void(^presentingBlock)(BOOL isPresenting);

/// 点击空白处收起 view controller, 默认 YES
@property (nonatomic, assign) BOOL dismissByTappingBlank;

@end

NS_ASSUME_NONNULL_END
