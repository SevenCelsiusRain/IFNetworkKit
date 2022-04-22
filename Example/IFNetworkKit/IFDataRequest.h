//
//  IFRequest.h
//  IFNetworkKit_Example
//
//  Created by MrGLZh on 2022/3/10.
//  Copyright © 2022 张高磊. All rights reserved.
//

#import <IFNetworkKit/IFNetworkKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IFDataRequest : IFBaseRequest
@property (nonatomic, copy) NSString *phoneNum;

@end

NS_ASSUME_NONNULL_END
