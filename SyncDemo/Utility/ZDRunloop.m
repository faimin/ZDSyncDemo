//
//  ZDRunloop.m
//  ZDSyncDemo
//
//  Created by Zero.D.Saber on 2019/9/25.
//  Copyright © 2019 ZD. All rights reserved.
//

#import "ZDRunloop.h"

@interface ZDRunloop ()
@property (nonatomic, strong) NSThread *thread;
@end

@implementation ZDRunloop

- (instancetype)init {
    if (self = [super init]) {
        _thread = [[NSThread alloc] initWithTarget:self selector:@selector(startRunloop) object:nil];
        [_thread start];
    }
    return self;
}

static void runloopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    
}

- (void)startRunloop {
    CFRunLoopObserverContext context = {
        0,
        (__bridge void *)self,
        &CFRetain,
        &CFRelease,
        NULL
    };
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                            kCFRunLoopExit,
                            true,
                            0,
                            &runloopObserverCallBack,
                            &context);
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopCommonModes);
    CFRelease(observer);
    
    CFRunLoopSourceContext sourceContext = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
    CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &sourceContext);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopCommonModes);
    CFRelease(source);
    
    CFRunLoopRun();
}

- (void)addTask:(void(^)( id(^callback)(id) ))taskBlock {
    __auto_type callback = ^id(id value) {
        CFRunLoopStop(CFRunLoopGetCurrent());
        NSLog(@"value = %@", value);
        return value;
    };
    
    taskBlock(callback);
    
    CFRunLoopRun();
}

@end
