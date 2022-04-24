#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "IFToast.h"
#import "IFToastView.h"
#import "UIView+IFNotiToast.h"

FOUNDATION_EXPORT double IFToastVersionNumber;
FOUNDATION_EXPORT const unsigned char IFToastVersionString[];

