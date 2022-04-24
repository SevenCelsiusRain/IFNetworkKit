//
//  IFToastView.h
//  IFToast
//
//  Created by MrGLZh on 2022/1/3.
//

#import <UIKit/UIKit.h>
#import <YYImage/YYImage.h>

typedef NS_ENUM(NSInteger, IFToastPositionType) {
    IFToastPositionTypeTop,
    IFToastPositionTypeCenter,
    IFToastPositionTypeBottom
};

@interface IFToastView : NSObject
/*!展示时长 默认 2s*/
@property (nonatomic, assign) CGFloat duration;
/*!是否可交互 默认 NO*/
@property (nonatomic, assign) BOOL userEnable;
/*!toast 颜色 默认 black alpha 0.8*/
@property (nonatomic, strong) UIColor *contentColor;
/*!蒙板颜色 默认 clear*/
@property (nonatomic, strong) UIColor *maskColor;
/*!文本颜色 默认 white*/
@property (nonatomic, strong) UIColor *textColor;
/*!文本字体 默认 16*/
@property (nonatomic, strong) UIFont *textFont;

/// 显示toast在中间
/// @param image 图片
/// @param text 文本
+ (void)showWithImage:(UIImage *)image text:(NSString *)text;

/// 显示toast
/// @param text 文本
/// @param positionType 位置
+ (void)showWithText:(NSString *)text positionType:(IFToastPositionType)positionType;

/// 显示toast
/// @param text 文本
/// @param duration 时长
/// @param positionType 位置
+ (void)showWithText:(NSString *)text duration:(CGFloat)duration positionType:(IFToastPositionType)positionType;

/// 显示toast
/// @param text 文本
/// @param duration 时长
/// @param offset 偏移量
/// @param positionType 位置
+ (void)showWithText:(NSString *)text duration:(CGFloat)duration offset:(CGFloat)offset positionType:(IFToastPositionType)positionType;

/// 显示toast
/// @param text 文本
/// @param duration 时长
/// @param offset 偏移量
/// @param userEnable 是否可以交互（拦截）
/// @param positionType 位置
+ (void)showWithText:(NSString *)text duration:(CGFloat)duration offset:(CGFloat)offset userEnable:(BOOL)userEnable positionType:(IFToastPositionType)positionType;

/// 显示toast 在中间
- (void)showInCenter;

/// 显示toast
/// @param view 承载视图
- (void)showInView:(UIView *)view;

/// 隐藏（无动画）
- (void)dismissToast;

/// 隐藏（有动画）
- (void)hideAnimation;

/// 构建 toast
/// @param text 文本
- (instancetype)initWithText:(NSString *)text;

/// 构建 toast
/// @param image 图片
/// @param text 文本
- (instancetype)initWithImage:(UIImage *)image text:(NSString *)text;

/// 构建 toast
/// @param image 图片（YYImage 类型）
/// tip:gif 图尺寸固定 30
- (instancetype)initWithImage:(YYImage *)image;

/// 构建toast
/// @param image image 图片（YYImage 类型）
/// @param text 文本
/// tip: GIF 尺寸随图
- (instancetype)initWithYYImage:(YYImage *)image text:(NSString *)text;

@end
