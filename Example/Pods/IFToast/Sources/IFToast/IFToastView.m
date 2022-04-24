//
//  IFToastView.m
//  IFToast
//
//  Created by MrGLZh on 2022/1/3.
//

#import "IFToastView.h"

@interface IFView : UIView
@end

static CGFloat displayDuration = 2.0;
@interface IFToastView()
@property (nonatomic, strong) IFView *bgView;
@property (nonatomic, strong) IFView *contentView;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) YYAnimatedImageView *yyImageView;

@end


@implementation IFToastView

- (instancetype)init {
    self = [super init];
    if (self) {
        _duration = 2.0;
        _textColor = UIColor.whiteColor;
        _contentColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        _maskColor = UIColor.clearColor;
        _textFont = [UIFont systemFontOfSize:16];
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text {
    self = [self init];
    if (self) {
        [self setupViewsWithImage:nil text:text];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image text:(NSString *)text {
    self = [self init];
    if (self) {
        [self setupViewsWithImage:image text:text];
    }
    return self;
}

- (instancetype)initWithImage:(YYImage *)image {
    self = [self init];
    if (self) {
        [self setupViewWithImage:image];
    }
    return self;
}

- (instancetype)initWithYYImage:(YYImage *)image text:(NSString *)text {
    self = [self init];
    if (self) {
        [self setupWithYYImage:image text:text];
    }
    return self;
}


#pragma mark - private methods

- (void)setupViewsWithImage:(UIImage *)image text:(NSString *)text {
    CGFloat imageWidth = 0;
    CGFloat imageHeight = 0;
    if (image) {
        imageWidth = image.size.width;
        imageHeight = image.size.height;
        self.imageView.image = image;
    }
    
    CGRect textRect = [text boundingRectWithSize:CGSizeMake(280, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.textFont} context:nil];
    
    CGFloat selfWidth = (imageWidth > textRect.size.width ? imageWidth:textRect.size.width) + 50;
    CGFloat selfHeight = imageHeight + textRect.size.height + 20;
    
    self.imageView.frame = CGRectMake((selfWidth - imageWidth)/2.0, 5, imageWidth, imageHeight);
    
    CGFloat yAxis = CGRectGetMaxY(self.imageView.frame) + 10;
    CGFloat textH = textRect.size.height;
    if (imageWidth == 0 && imageHeight == 0) {
        yAxis = 0;
        textH = selfHeight;
    }
    self.textLabel.text = text;
    self.textLabel.frame = CGRectMake(0, yAxis, selfWidth, textH);
    self.contentView.frame = CGRectMake(0, 0, selfWidth, selfHeight);
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.textLabel];
}

- (void)setupViewWithImage:(YYImage *)image {
    
    self.yyImageView.image = image;
    self.bgView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    
    CGFloat width = 30;
    self.contentView.frame = CGRectMake(0, 0, width + 50, width + 50);
    [self.contentView addSubview:self.yyImageView];
    self.yyImageView.frame = CGRectMake(0, 0, width, width);
    self.yyImageView.center = self.contentView.center;
}

- (void)setupWithYYImage:(YYImage *)image text:(NSString *)text {
    CGFloat imageWidth = 0;
    CGFloat imageHeight = 0;
    if (image) {
        imageWidth = image.size.width;
        imageHeight = image.size.height;
        self.yyImageView.image = image;
    }
    
    CGRect textRect = [text boundingRectWithSize:CGSizeMake(280, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.textFont} context:nil];
    
    CGFloat selfWidth = (imageWidth > textRect.size.width ? imageWidth:textRect.size.width) + 50;
    CGFloat selfHeight = imageHeight + textRect.size.height + 20;
    
    self.yyImageView.frame = CGRectMake((selfWidth - imageWidth)/2.0, 5, imageWidth, imageHeight);
    CGFloat yAxis = CGRectGetMaxY(self.yyImageView.frame) + 10;
    CGFloat textH = textRect.size.height;
    if (imageWidth == 0 && imageHeight == 0) {
        yAxis = 0;
        textH = selfHeight;
    }
    self.textLabel.text = text;
    self.textLabel.frame = CGRectMake(0, yAxis, selfWidth, textH);
    self.contentView.frame = CGRectMake(0, 0, selfWidth, selfHeight);
    [self.contentView addSubview:self.yyImageView];
    [self.contentView addSubview:self.textLabel];
}

- (BOOL)shouldShowToast {
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if (!window) {
        return NO;
    }
    
    NSInteger index = 0;
    for (UIView *view in window.subviews) {
        if ([view isMemberOfClass:IFView.class]) {
            index += 1;
        }
    }
    return index == 0;
}

- (void)showFromCenterOffset:(CGFloat)centerOffset {
    if (![self shouldShowToast]) {
        return;
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.contentView.center = window.center;
    [window addSubview:self.bgView];
    [window addSubview:self.contentView];
    [self showAnimation];
    [self performSelector:@selector(hideAnimation) withObject:nil afterDelay:self.duration];
}

- (void)showFromTopOffset:(CGFloat)topOffset {
    if (![self shouldShowToast]) {
        return;
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.contentView.center = CGPointMake(window.center.x, topOffset + self.contentView.frame.size.height/2.0);
    [window addSubview:self.bgView];
    [window addSubview:self.contentView];
    [self showAnimation];
    [self performSelector:@selector(hideAnimation) withObject:nil afterDelay:self.duration];
}

- (void)showFromBottonOffset:(CGFloat)bottomOffset {
    if (![self shouldShowToast]) {
        return;
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.contentView.center = CGPointMake(window.center.x, window.frame.size.height - (bottomOffset + self.contentView.frame.size.height/2.0));
    [window addSubview:self.bgView];
    [window addSubview:self.contentView];
    [self showAnimation];
    [self performSelector:@selector(hideAnimation) withObject:nil afterDelay:self.duration];
}

- (void)dismissToast {
    [self.bgView removeFromSuperview];
    [self.contentView removeFromSuperview];
}

- (void)showAnimation {
    [UIView beginAnimations:@"show" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
}

- (void)hideAnimation {
    [UIView beginAnimations:@"hide" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(dismissToast)];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
}


#pragma mark - public mehods

+ (void)showWithText:(NSString *)text positionType:(IFToastPositionType)positionType {
    [self showWithText:text duration:displayDuration positionType:positionType];
}

+ (void)showWithText:(NSString *)text duration:(CGFloat)duration positionType:(IFToastPositionType)positionType {
    CGFloat offset = 0;
    if (positionType != IFToastPositionTypeCenter) {
        offset = 100;
    }
    [self showWithText:text duration:duration offset:offset positionType:positionType];
}

+ (void)showWithText:(NSString *)text duration:(CGFloat)duration offset:(CGFloat)offset positionType:(IFToastPositionType)positionType {
    IFToastView *toast = [[IFToastView alloc] initWithText:text];
    toast.duration = duration;
    
    switch (positionType) {
        case IFToastPositionTypeTop:
            [toast showFromTopOffset:offset];
            break;
            
        case IFToastPositionTypeBottom:
            [toast showFromBottonOffset:offset];
            break;
            
        case IFToastPositionTypeCenter:
            [toast showFromCenterOffset:offset];
            break;
            
        default:
            break;
    }
}

+ (void)showWithText:(NSString *)text duration:(CGFloat)duration offset:(CGFloat)offset userEnable:(BOOL)userEnable positionType:(IFToastPositionType)positionType {
    IFToastView *toast = [[IFToastView alloc] initWithText:text];
    toast.duration = duration;
    toast.userEnable = userEnable;
    switch (positionType) {
        case IFToastPositionTypeTop:
            [toast showFromTopOffset:offset];
            break;
            
        case IFToastPositionTypeBottom:
            [toast showFromBottonOffset:offset];
            break;
            
        case IFToastPositionTypeCenter:
            [toast showFromCenterOffset:offset];
            break;
            
        default:
            break;
    }
}

+ (void)showWithImage:(UIImage *)image text:(NSString *)text {
    IFToastView *toast = [[IFToastView alloc] initWithImage:image text:text];
    toast.duration = displayDuration;
    [toast showFromCenterOffset:0];
}

- (void)showInCenter {
    if (![self shouldShowToast]) {
        return;
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.contentView.center = window.center;
    [window addSubview:self.bgView];
    [window addSubview:self.contentView];
    [self showAnimation];
}

- (void)showInView:(UIView *)view {
    if (![self shouldShowToast]) {
        return;
    }
    self.contentView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
    [view addSubview:self.bgView];
    [view addSubview:self.contentView];
    [self showAnimation];
}


#pragma mark - getter

- (IFView *)bgView {
    if (!_bgView) {
        _bgView = [[IFView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
        _bgView.backgroundColor = self.maskColor;
    }
    return _bgView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
    }
    return _imageView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [UILabel new];
        _textLabel.textColor = self.textColor;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = self.textFont;
        _textLabel.numberOfLines = 0;
    }
    return _textLabel;
}

- (IFView *)contentView {
    if (!_contentView) {
        _contentView = [IFView new];
        _contentView.layer.cornerRadius = 8;
        _contentView.backgroundColor = self.contentColor;
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _contentView;
}

- (YYAnimatedImageView *)yyImageView {
    if (!_yyImageView) {
        _yyImageView = [[YYAnimatedImageView alloc] init];
    }
    return _yyImageView;
}

- (void)setUserEnable:(BOOL)userEnable {
    _userEnable = userEnable;
    self.bgView.userInteractionEnabled = userEnable;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.textLabel.textColor = textColor;
}

- (void)setContentColor:(UIColor *)contentColor {
    _contentColor = contentColor;
    self.contentView.backgroundColor = contentColor;
}

- (void)setMaskColor:(UIColor *)maskColor {
    _maskColor = maskColor;
    self.bgView.backgroundColor = maskColor;
}

@end


@implementation IFView

@end
