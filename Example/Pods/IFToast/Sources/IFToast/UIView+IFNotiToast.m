//
//  UIView+IFNotiToast.m
//  IFToast
//
//  Created by MrGLZh on 2022/3/8.
//

#import <objc/runtime.h>
#import "UIView+IFNotiToast.h"

@interface UIView ()
@property (nonatomic, strong) IFNotiToastConfig *config;
@end

static NSString *if_config_key = @"if_config_key";
@implementation UIView (IFNotiToast)

- (void)showNotiToastWithConfig:(void (^)(IFNotiToastConfig *))config {
    if (config) {
        config(self.config);
    }
    if (self.config.text.length == 0 && self.config.image == nil && self.config.subtitleText.length == 0) {
        return;
    }
    
    [CRToastManager showNotificationWithOptions:self.config.options completionBlock:nil];
}

- (void)showNotiToastWithConfig:(void (^)(IFNotiToastConfig *))config completion:(void (^)(void))completion {
    if (config) {
        config(self.config);
    }
    if (self.config.text.length == 0 && self.config.image == nil && self.config.subtitleText.length == 0) {
        return;
    }
    [CRToastManager showNotificationWithOptions:self.config.options completionBlock:completion];
}

- (void)showNotiToastWithConfig:(void (^)(IFNotiToastConfig *))config appearance:(void (^)(void))appearance completion:(void (^)(void))completion {
    if (config) {
        config(self.config);
    }
    if (self.config.text.length == 0 && self.config.image == nil && self.config.subtitleText.length == 0) {
        return;
    }
    [CRToastManager showNotificationWithOptions:self.config.options apperanceBlock:appearance completionBlock:completion];
}


#pragma mark - getter & setter

- (IFNotiToastConfig *)config {
    IFNotiToastConfig *config = objc_getAssociatedObject(self, &if_config_key);
    if (!config) {
        config = [IFNotiToastConfig config];
        self.config = config;
    }
    return config;
}

- (void)setConfig:(IFNotiToastConfig *)config {
    objc_setAssociatedObject(self, &if_config_key, config, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@implementation IFNotiToastConfig

+ (instancetype)config {
    IFNotiToastConfig *config = [IFNotiToastConfig new];
    return config;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _textFont = [UIFont systemFontOfSize:16];
        _textColor = UIColor.blackColor;
        _backgroundColor = UIColor.whiteColor;
        _inType = CRToastAnimationTypeGravity;
        _outType = CRToastAnimationTypeGravity;
        _inDirection = CRToastAnimationDirectionTop;
        _outDirection = CRToastAnimationDirectionTop;
        _toastType = CRToastTypeNavigationBar;
        _textAlignment = NSTextAlignmentLeft;
        _imageAlignment = CRToastAccessoryViewAlignmentLeft;
        _subtitleColor = UIColor.blackColor;
        _subtitleAlignment = NSTextAlignmentLeft;
        _subtitleFont = [UIFont systemFontOfSize:12];
        _duration = 1;
        _underStatusBar = YES;
    }
    return self;
}


#pragma mark - getter

- (NSDictionary *)options {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.text.length > 0) {
        [dict setObject:self.text forKey:kCRToastTextKey];
        [dict setObject:self.textColor forKey:kCRToastTextColorKey];
        [dict setObject:self.textFont forKey:kCRToastFontKey];
        [dict setObject:@(self.textAlignment) forKey:kCRToastTextAlignmentKey];
    }
    if (self.subtitleText.length > 0) {
        [dict setObject:self.subtitleText forKey:kCRToastSubtitleTextKey];
        [dict setObject:self.subtitleFont forKey:kCRToastSubtitleFontKey];
        [dict setObject:self.subtitleColor forKey:kCRToastSubtitleTextColorKey];
        [dict setObject:@(self.subtitleAlignment) forKey:kCRToastSubtitleTextAlignmentKey];
    }
    if (self.image) {
        [dict setObject:self.image forKey:kCRToastImageKey];
        [dict setObject:@(self.imageAlignment) forKey:kCRToastImageAlignmentKey];
        [dict setObject:@(self.imageContentMode) forKey:kCRToastImageContentModeKey];
    }
    if (self.preferredHeight > 0 && self.toastType == CRToastTypeCustom) {
        [dict setObject:@(self.preferredHeight) forKey:kCRToastNotificationPreferredHeightKey];
    }
    if (self.responder && self.responder.count > 0) {
        [dict setObject:self.responder forKey:kCRToastInteractionRespondersKey];
    }
    
    if (self.customBackgroundView) {
        [dict setObject:self.customBackgroundView forKey:kCRToastBackgroundViewKey];
    }
    
    [dict setObject:@(self.toastType) forKey:kCRToastNotificationTypeKey];
    [dict setObject:@(self.inType) forKey:kCRToastAnimationInTypeKey];
    [dict setObject:@(self.outType) forKey:kCRToastAnimationOutTypeKey];
    [dict setObject:@(self.inDirection) forKey:kCRToastAnimationInDirectionKey];
    [dict setObject:@(self.outDirection) forKey:kCRToastAnimationOutDirectionKey];
    [dict setObject:self.backgroundColor forKey:kCRToastBackgroundColorKey];
    [dict setObject:@(self.duration) forKey:kCRToastTimeIntervalKey];
    [dict setObject:@(self.underStatusBar) forKey:kCRToastUnderStatusBarKey];
    [dict setObject:@(UIStatusBarStyleLightContent) forKey:kCRToastStatusBarStyleKey];
    
    return dict.copy;
}

@end
