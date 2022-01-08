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

#import "IFAFJSONResponseSerializer.h"
#import "IFBaseRequest.h"
#import "IFCommonRequestManager.h"
#import "IFDefaultErrorMessage.h"
#import "IFErrorMessageProtocol.h"
#import "IFErrorResponseModel.h"
#import "IFArrayValueTransformer.h"
#import "IFDictionaryValueTransformer.h"
#import "IFModel.h"
#import "IFModelUtil.h"
#import "IFValueTransformer.h"
#import "NSObject+IFModel.h"
#import "NSString+IFModel.h"
#import "IFModelRequest.h"
#import "IFModelSerialization.h"
#import "IFNetworkConfig.h"
#import "IFNetworkConfigManager.h"
#import "IFNetworkDefines.h"
#import "IFNetworkKit.h"
#import "IFNetworkPrivateUtils.h"
#import "IFRequestCache.h"
#import "IFRequestFilter.h"
#import "IFRequestManager.h"
#import "IFRequestSignature.h"
#import "IFRequestSignMethod.h"
#import "IFResponseModel.h"
#import "IFStubRequestManager.h"
#import "IFArrayValueTransformer.h"
#import "IFDictionaryValueTransformer.h"
#import "IFModel.h"
#import "IFModelUtil.h"
#import "IFValueTransformer.h"
#import "NSObject+IFModel.h"
#import "NSString+IFModel.h"

FOUNDATION_EXPORT double IFNetworkKitVersionNumber;
FOUNDATION_EXPORT const unsigned char IFNetworkKitVersionString[];

