//
//  IFNetworkPrivateUtils.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import <Foundation/Foundation.h>
#import "IFBaseRequest.h"
#import "IFRequestManager.h"
#import "IFNetworkConfig.h"
#import "IFModelRequest.h"

FOUNDATION_EXTERN NSString * const kIFDefaultRequestCategoryName;

@interface IFBaseRequest (Private)

@property (nonatomic, strong, readwrite) NSString *requestURL;
@property (nonatomic, assign, readwrite) IFHTTPRequestMethod httpMethod;

@property (nonatomic, assign, readwrite) NSInteger statusCode;
@property (nonatomic, strong, readwrite) NSData *responseData;
@property (nonatomic, strong, readwrite) NSString *responseString;
@property (nonatomic, strong, readwrite) id responseJSONObject;
@property (nonatomic, strong, readwrite) id responseObject;
@property (nonatomic, strong, readwrite) NSURLSessionTask *sessionTask;

@property (nonatomic, strong) id validData;
@property (nonatomic, weak) IFNetworkConfig *requestConfig;

@end

@interface IFModelRequest (Private)

@property (nonatomic, strong, readwrite) NSString *responseModelClass;
@property (nonatomic, strong, readwrite) NSDictionary<NSString *, NSString *> *keyClassMapper;
@property (nonatomic, strong, readwrite) NSDictionary<NSString *, NSString *> *keyPropertyMapper;

@end

@interface IFBaseRequest (RequestAccessory)

- (void)if_accessoriesWillStart;
- (void)if_accessoriesWillStop;
- (void)if_accessoriesDidStop;

@end

@interface IFRequestManager (Private)

+ (instancetype)sharedRequestManager;

- (void)addRequest:(IFBaseRequest *)request;
- (void)cancelRequest:(IFBaseRequest *)request;

@end

@interface IFNetworkConfig (Logger)

- (void)logMessage:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);

@end

@interface IFNetworkUtil : NSObject

+ (NSStringEncoding)stringEncodingForRequest:(IFBaseRequest *)request;
+ (NSString *)md5:(NSString *)content;
+ (BOOL)validateResumeData:(NSData *)data;

@end

