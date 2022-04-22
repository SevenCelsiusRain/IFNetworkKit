//
//  IFDemoFilter.m
//  IFNetworkKit_Example
//
//  Created by MrGLZh on 2022/4/22.
//  Copyright © 2022 张高磊. All rights reserved.
//

#import "IFDemoFilter.h"

@implementation IFDemoFilter

- (BOOL)filter:(__kindof IFBaseRequest *)request {
    // 进行特殊响应码过滤
    NSObject *obj = request.responseObject;
    
    if ([request.responseObject isKindOfClass:IFResponseModel.class]) {
        IFResponseModel *model = (IFResponseModel *)request.responseObject;
        if (model.apiCode == 2000) {
            return YES;
        }
        
    }
    return NO;
}

@end
