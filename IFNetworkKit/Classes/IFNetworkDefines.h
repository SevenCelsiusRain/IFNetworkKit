//
//  IFNetworkDefines.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/6.
//

#ifndef IFNetworkDefines_h
#define IFNetworkDefines_h

#define if_network_weakify(obj) __weak typeof(obj) weak_obj = obj
#define if_network_strongify(obj) __strong typeof(weak_obj) obj = weak_obj

#endif /* IFNetworkDefines_h */
