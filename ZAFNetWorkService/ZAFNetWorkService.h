//
//  ZAFNetWorkService.h
//  RequestNetWork
//
//  Created by apple on 14/11/21.
//  Copyright (c) 2014年 Fate.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

///用于回调请求成功或者失败的信息
typedef void (^SuccessHandle)(id responseObject);
typedef void (^FailureHandle)(NSError *error);

typedef NS_ENUM(NSInteger, HTTPMethod) {
    HTTPMethod_GET,
    HTTPMethod_POST,
};

@interface ZAFNetWorkService : NSObject

/**
 *  单例
 *
 *  @return 实例化后的selfClass
 */
+ (instancetype)shareInstance;

/**
 *  @abstract GET && POST请求
 *
 *  @param urlString : 请求地址
 *  @param params : 请求参数
 *  @param httpMethod : GET/POST 请求
 *  @param hasCer : 是否有证书（对于Https请求）
 *  @param successBlock/failureBlock : 回调block
 *
 *  @discussion
 */
- (AFHTTPRequestOperation *)requestWithURL:(NSString *)URLString params:(id)params httpMethod:(HTTPMethod)httpMethod hasCertificate:(BOOL)hasCer sucess:(SuccessHandle)successBlock failure:(FailureHandle)failureBlock;

@end
