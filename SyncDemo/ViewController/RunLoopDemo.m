//
//  RunLoopDemo.m
//  ZDSyncDemo
//
//  Created by Zero.D.Saber on 16/7/26.
//  Copyright © 2016年 ZD. All rights reserved.
//

#import "RunLoopDemo.h"
#import "ZDCommon.h"
#import "ZDRunloop.h"

@interface RunLoopDemo ()
@property (nonatomic, strong) ZDRunloop *zdRunloop;
@end

@implementation RunLoopDemo

- (void)dealloc {
    NSLog(@"RunLoopDemo成功释放了");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = ZD_RandomColor();
    
    self.zdRunloop = ZDRunloop.new;
    
//    [self runloopDemo];
    [self netTask];
}

- (void)netTask {
    [self.zdRunloop addTask:^(id  _Nonnull (^ _Nonnull callback)(id _Nonnull)) {
        [[ZAFNetWorkService shareInstance] requestWithURL:WeatherAPI params:nil httpMethod:@"get" hasCertificate:NO sucess: ^(id responseObject) {
            callback(responseObject);
        } failure: ^(NSError *error) {
            callback(error);
        }];
    }];
    
    NSLog(@"============================");
}

- (void)runloopDemo {
    __block id result = nil;
    [[ZAFNetWorkService shareInstance] requestWithURL:MovieAPI params:nil httpMethod:@"get" hasCertificate:NO sucess: ^(id responseObject) {
        result = responseObject;
        CFRunLoopStop(CFRunLoopGetMain());
    } failure: ^(NSError *error) {
        result = error;
        CFRunLoopStop(CFRunLoopGetMain());
    }];
    // 阻塞主线程的方法,不推荐
    // 当调用 CFRunLoopRun() 时，线程就会一直停留在这个循环里；直到超时或被手动停止，该函数才会返回。
    CFRunLoopRun();

    NSLog(@"%@", result);
    NSLog(@"finish");
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
