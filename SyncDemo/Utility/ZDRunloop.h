//
//  ZDRunloop.h
//  ZDSyncDemo
//
//  Created by Zero.D.Saber on 2019/9/25.
//  Copyright © 2019 ZD. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDRunloop : NSObject

- (void)addTask:(void(^)( id(^callback)(id) ))taskBlock;

@end

NS_ASSUME_NONNULL_END
