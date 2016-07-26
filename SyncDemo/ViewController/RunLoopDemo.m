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
    
    [self af];
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
    // 阻塞主线程的方法
    CFRunLoopRun();
    
    NSLog(@"%@", result);
    NSLog(@"finish");
}

- (void)af {
    AFHTTPRequestOperation *operation1 = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:MovieAPI]]];
    [operation1 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@", [self decodeData:responseObject]);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    [operation1 resume];
    
    AFHTTPRequestOperation *operation2 = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:WeatherAPI]]];
    [operation2 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@", [self decodeData:responseObject]);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    [operation2 resume];
    
    NSArray *operations = [AFHTTPRequestOperation batchOfRequestOperations:@[operation1, operation2] progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"%ld/%ld", numberOfFinishedOperations, totalNumberOfOperations);
    } completionBlock:^(NSArray * _Nonnull operations) {
        NSLog(@"批处理结束");
    }];
    
    [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
    NSLog(@"打印一下");
}

- (id)decodeData:(id)data {
    NSError *error;
    return [data isKindOfClass:[NSData class]] ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error] : data;
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
