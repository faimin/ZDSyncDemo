//
//  ZDSerialOperation.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2019/5/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ZDOnComplteBlock)(BOOL isTaskFinish);
typedef void(^ZDOperationBlock)(ZDOnComplteBlock taskFinishCallback);

@interface ZDSerialOperation : NSOperation

+ (instancetype)operationWithBlock:(ZDOperationBlock)block;

@end

NS_ASSUME_NONNULL_END
