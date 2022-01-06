//
//  IFModelRequest.m
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/6.
//

#import "IFModelRequest.h"
#import "IFResponseModel.h"
#import "IFModelSerialization.h"
#import "IFNetworkPrivateUtils.h"

@interface IFModelRequest ()
@property (nonatomic, strong, readwrite) NSString *responseModelClass;
@property (nonatomic, strong, readwrite) NSDictionary<NSString *, NSString *> *keyClassMapper;
@property (nonatomic, strong, readwrite) NSDictionary<NSString *, NSString *> *keyPropertyMapper;

@end

@implementation IFModelRequest

#pragma mark - Private Methods

- (IFResponseSerializerType)responseSerializerType {
    return IFResponseSerializerTypeJSON;
}

- (id<IFResponseSerialization>)responseSerialization {
    return [[IFModelSerialization alloc] init];
}

@end
