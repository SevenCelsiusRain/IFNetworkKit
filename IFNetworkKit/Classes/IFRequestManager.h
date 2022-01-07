//
//  IFRequestManager.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import <Foundation/Foundation.h>

@interface IFRequestManager : NSObject
+ (void)cancelAllRequests;
+ (void)cancelAllRequestsInCategory:(NSString *)category;
@end

