//
//  ZDTask.m
//  ZDSyncDemo
//
//  Created by Zero.D.Saber on 16/5/6.
//  Copyright © 2016年 ZD. All rights reserved.
//

#import "ZDTask.h"

typedef void(^BlockAction)(void);
typedef void(^GroupResponseFailure)(NSArray * errorArray);

//static char groupErrorKey;
//static char queueGroupKey;

const void *key = &key;

@interface ZDTask ()

@end

@implementation ZDTask

+ (instancetype)task {
    return [[self alloc] init];
}

- (void)testWithBlock:(void(^)(void))completeBlock {
    dispatch_group_t zdGroup = dispatch_group_create();
    dispatch_queue_t zdQueue = dispatch_queue_create("ZDTaskQueue", DISPATCH_QUEUE_CONCURRENT);
    
    
    dispatch_group_notify(zdGroup, zdQueue, ^{
        NSLog(@"任务结束");
        completeBlock();
    });
}

@end
