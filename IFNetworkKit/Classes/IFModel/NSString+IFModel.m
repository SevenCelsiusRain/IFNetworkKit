//
//  NSString+IFModel.m
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import "NSString+IFModel.h"
#import "NSObject+IFModel.h"

@implementation NSString (IFModel)
- (id)if_jsonStringToModel:(Class)modelClass error:(NSError **)error {
    
    if (!modelClass) {
        return nil;
    }
    
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        return nil;
    }
    
    NSError *innerError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&innerError];
    
    if (innerError && error != NULL) {
        *error = innerError;
    }
    
    if (!jsonObject) {
        return nil;
    }
    
    return [modelClass if_modelWithJSON:jsonObject
                            mapperConfig:nil
                       keyPropertyMapper:nil];
}

@end
