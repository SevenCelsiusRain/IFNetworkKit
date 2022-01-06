//
//  IFNetworkPrivateUtils.m
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import <CommonCrypto/CommonDigest.h>
#import "IFNetworkPrivateUtils.h"

NSString * const kIFDefaultRequestCategoryName = @"if_default";

@implementation IFBaseRequest (RequestAccessory)

- (void)if_accessoriesWillStart {
    for (id<IFRequestAccessory> accessory in self.requestAccessories) {
        if ([accessory respondsToSelector:@selector(if_requestWillStart:)]) {
            [accessory if_requestWillStart:self];
        }
    }
}

- (void)if_accessoriesWillStop {
    for (id<IFRequestAccessory> accessory in self.requestAccessories) {
        if ([accessory respondsToSelector:@selector(if_requestWillStop:)]) {
            [accessory if_requestWillStop:self];
        }
    }
}

- (void)if_accessoriesDidStop {
    for (id<IFRequestAccessory> accessory in self.requestAccessories) {
        if ([accessory respondsToSelector:@selector(if_requestDidStop:)]) {
            [accessory if_requestDidStop:self];
        }
    }
}

@end

@implementation IFNetworkConfig (Logger)

- (void)logMessage:(NSString *)format, ... {
#ifdef DEBUG
    if (!self.debugEnabled) {
        return;
    }
    va_list argptr;
    va_start(argptr, format);
    NSLogv(format, argptr);
    va_end(argptr);
#endif
}

@end

@implementation IFNetworkUtil

+ (NSStringEncoding)stringEncodingForRequest:(IFBaseRequest *)request {
    NSStringEncoding stringEncoding = NSUTF8StringEncoding;
    if (request.response.textEncodingName) {
        CFStringRef encodingName  = (__bridge CFStringRef)request.response.textEncodingName;
        CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding(encodingName);
        if (encoding != kCFStringEncodingInvalidId) {
            stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
        }
    }
    return stringEncoding;
}

+ (NSString *)md5:(NSString *)content {
    NSParameterAssert(content != nil && [content length] > 0);
    
    const char *value = [content UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x", outputBuffer[count]];
    }
    
    return outputString;
}

+ (BOOL)validateResumeData:(NSData *)data {
    // From http://stackoverflow.com/a/22137510/3562486
    if (!data || [data length] < 1) return NO;
    
    NSError *error = nil;
    NSDictionary *resumeDictionary = [NSPropertyListSerialization propertyListWithData:data
                                                                               options:NSPropertyListImmutable
                                                                                format:NULL
                                                                                 error:&error];
    if (!resumeDictionary || error) return NO;
    if (@available(iOS 9.0, *)) {
        return YES;
    }
    
    // Before iOS 9
    NSString *localFilePath = resumeDictionary[@"NSURLSessionResumeInfoLocalPath"];
    if ([localFilePath length] < 1) return NO;
    return [[NSFileManager defaultManager] fileExistsAtPath:localFilePath];
}

@end

