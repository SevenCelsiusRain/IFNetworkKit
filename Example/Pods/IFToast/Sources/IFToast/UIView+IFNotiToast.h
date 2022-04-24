//
//  UIView+IFNotiToast.h
//  IFToast
//
//  Created by MrGLZh on 2022/3/8.
//

#import <UIKit/UIKit.h>
#import <CRToast/CRToast.h>

@class IFNotiToastConfig;
@interface UIView (IFNotiToast)
@property (nonatomic, strong, readonly) IFNotiToastConfig *config;

- (void)showNotiToastWithConfig:(void(^)(IFNotiToastConfig *config))config;

- (void)showNotiToastWithConfig:(void(^)(IFNotiToastConfig *config))config completion:(void(^)(void))completion;

- (void)showNotiToastWithConfig:(void(^)(IFNotiToastConfig *config))config appearance:(void(^)(void))appearance completion:(void(^)(void))completion;

@end


@interface IFNotiToastConfig : NSObject
@property (nonatomic, copy) NSString *text;
/*!文本颜色 默认 black*/
@property (nonatomic, strong) UIColor *textColor;
/*!文本字体 默认 16*/
@property (nonatomic, strong) UIFont *textFont;
/*!文本对齐方式 默认 NSTextAlignmentLeft*/
@property (nonatomic, assign) NSTextAlignment textAlignment;

@property (nonatomic, strong) UIImage *image;
/*!图片对齐方式 默认 CRToastAccessoryViewAlignmentLeft*/
@property (nonatomic, assign) CRToastAccessoryViewAlignment imageAlignment;
/*!图片填充模式 默认 UIViewContentModeCenter*/
@property (nonatomic, assign) UIViewContentMode imageContentMode;

@property (nonatomic, copy) NSString *subtitleText;
/*!副标题文本颜色 默认 black*/
@property (nonatomic, strong) UIColor *subtitleColor;
/*!副标题字体大小 默认 12*/
@property (nonatomic, strong) UIFont *subtitleFont;
/*!副标题对齐方式 默认 NSTextAlignmentLeft*/
@property (nonatomic, assign) NSTextAlignment subtitleAlignment;

/*!背景色 默认 white*/
@property (nonatomic, strong) UIColor *backgroundColor;
/*!显示动画 默认 CRToastAnimationTypeGravity*/
@property (nonatomic, assign) CRToastAnimationType inType;
/*!隐藏动画 默认 CRToastAnimationTypeGravity*/
@property (nonatomic, assign) CRToastAnimationType outType;
/*!显示方向 默认 CRToastAnimationDirectionTop*/
@property (nonatomic, assign) CRToastAnimationDirection inDirection;
/*!隐藏方向 默认 CRToastAnimationDirectionTop*/
@property (nonatomic, assign) CRToastAnimationDirection outDirection;
/*!toast 类型 默认 CRToastTypeNavigationBar*/
@property (nonatomic, assign) CRToastType toastType;
/*! 时长 默认 1s*/
@property (nonatomic, assign) CGFloat duration;
/*!位置是否在状态栏之下 默认 YES*/
@property (nonatomic, assign) BOOL underStatusBar;
/*!高度 toastType 为 CRToastTypeCustom 才生效*/
@property (nonatomic, assign) CGFloat preferredHeight;
/*!手势响应 默认 无 nil*/
@property (nonatomic, copy) NSArray<CRToastInteractionResponder *>* responder;

@property (nonatomic, strong) UIView *customBackgroundView;

@property (nonatomic, readonly, strong) NSDictionary *options;

+ (instancetype)config;

@end
