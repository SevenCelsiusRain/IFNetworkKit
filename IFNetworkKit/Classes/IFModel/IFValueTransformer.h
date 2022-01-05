//
//  IFValueTransformer.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#ifndef IFValueTransformer_h
#define IFValueTransformer_h

@protocol IFValueTransformer <NSObject>

@required
- (id)transformValueFromOrigin:(id)originValue;

@end

#endif /* IFValueTransformer_h */
