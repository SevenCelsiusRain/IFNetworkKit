//
//  IFAFJSONResponseSerializer.m
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/6.
//

#import "IFAFJSONResponseSerializer.h"

@interface IFAFJSONResponseSerializer ()

@end

@implementation IFAFJSONResponseSerializer

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.acceptableContentTypes = nil;
    return self;
}

@end
