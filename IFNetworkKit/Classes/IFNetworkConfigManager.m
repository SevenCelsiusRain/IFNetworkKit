//
//  IFNetworkConfigManager.m
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/6.
//

#import "IFNetworkConfigManager.h"
#import "IFNetworkConfig.h"
#import "IFBaseRequest.h"
#import "IFNetworkPrivateUtils.h"

@interface IFNetworkConfigManager ()

@property (nonatomic, strong) NSMutableDictionary *configs;

@end

@implementation IFNetworkConfigManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _configs = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (IFNetworkConfigManager *)sharedConfigManager {
    static IFNetworkConfigManager *_sharedConfigManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedConfigManager = [[IFNetworkConfigManager alloc] init];
    });
    
    return _sharedConfigManager;
}

#pragma mark - Private Methods

- (IFNetworkConfig *)configForCategory:(NSString *)category {
    if (!category) {
        return nil;
    }
    
    IFNetworkConfig *networkConfig = _configs[category];
    if (!networkConfig) {
        networkConfig = [IFNetworkConfig networkConfig];
        _configs[category] = networkConfig;
    }
    return networkConfig;
}

- (void)updateNetworkConfig:(IFNetworkConfigBlock)configBlock forCategory:(NSString *)category {
    if (!category) {
        return;
    }
    if (configBlock) {
        configBlock([self configForCategory:category]);
    } else {
        _configs[category] = nil;
    }
}


#pragma mark - Public Methods

+ (IFNetworkConfig *)configForCategory:(NSString *)category {
    return [[self sharedConfigManager] configForCategory:category];
}

+ (void)updateDefaultNetworkConfig:(IFNetworkConfigBlock)configBlock {
    [[self sharedConfigManager] updateNetworkConfig:configBlock forCategory:kIFDefaultRequestCategoryName];
}

+ (void)updateNetworkConfig:(IFNetworkConfigBlock)configBlock forCategory:(NSString *)category {
    [[self sharedConfigManager] updateNetworkConfig:configBlock forCategory:category];
}

+ (NSString *)currentSDKVersion {
    return @"0.0.0.1";
}

@end

