//
//  RunLoopDemo.m
//  ZDSyncDemo
//
//  Created by 符现超 on 16/7/26.
//  Copyright © 2016年 ZD. All rights reserved.
//

#import "RunLoopDemo.h"
#import "ZDCommon.h"
#import "AFNetworking.h"

@interface RunLoopDemo ()

@end

@implementation RunLoopDemo

- (void)dealloc {
    NSLog(@"RunLoopDemo成功释放了");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self runloop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// http://www.jianshu.com/p/34d2b6c7de8a
- (void)runloop {
    __block id result = nil;
    [[ZAFNetWorkService shareInstance] requestWithURL:MovieAPI params:nil httpMethod:@"get" hasCertificate:NO sucess: ^(id responseObject) {
        result = responseObject;
        CFRunLoopStop(CFRunLoopGetMain());
    } failure: ^(NSError *error) {
        result = error;
        CFRunLoopStop(CFRunLoopGetMain());
    }];
    // 阻塞主线程的方法,不推荐
    CFRunLoopRun();
    
    NSLog(@"%@", result);
    NSLog(@"finish");
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    
}

- (void)test {
    CFRunLoopObserverContext context = {
        0,
        (__bridge void *)self,
        &CFRetain,
        &CFRelease,
        NULL
    };
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                            kCFRunLoopAllActivities,
                            YES,
                            0,
                            &runLoopObserverCallBack,
                            &context);
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopCommonModes);
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
