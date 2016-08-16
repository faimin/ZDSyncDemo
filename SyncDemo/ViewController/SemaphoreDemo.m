//
//  SemaphoreDemo.m
//  ZDSyncDemo
//
//  Created by 符现超 on 16/8/16.
//  Copyright © 2016年 ZD. All rights reserved.
//

#import "SemaphoreDemo.h"
#import "ZDCommon.h"

@interface SemaphoreDemo ()

@end

@implementation SemaphoreDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 信号量会阻塞线程,所以在子线程处理
    dispatch_queue_t myQueue = dispatch_queue_create("MyQueue.zd", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(myQueue, ^{
        //[self semaphore];
        [self semaphoreTempWithResult:^(id result) {
            NSLog(@"回调成功");
        }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)semaphore {
    NSMutableArray *allDatas = [[NSMutableArray alloc] init];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSURLSessionDataTask *task1 = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:MovieAPI] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [allDatas addObject:[self parase:data]];
        dispatch_semaphore_signal(semaphore);
    }];
    [task1 resume];
    
    NSURLSessionDataTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:WeatherAPI] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [allDatas addObject:[self parase:data]];
        dispatch_semaphore_signal(semaphore);
    }];
    [task2 resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    NSLog(@"总数据:\n%@", allDatas);
}

- (void)semaphoreTempWithResult:(void(^)(id result))block {
    NSMutableArray *allDatas = [[NSMutableArray alloc] init];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [[ZAFNetWorkService shareInstance] requestWithURL:MovieAPI params:nil httpMethod:@"get" hasCertificate:NO sucess: ^(id responseObject) {
        [allDatas addObject:responseObject];
        dispatch_semaphore_signal(semaphore);
    } failure: ^(NSError *error) {
        dispatch_semaphore_signal(semaphore);
    }];

    [[ZAFNetWorkService shareInstance] requestWithURL:WeatherAPI params:nil httpMethod:@"get" hasCertificate:NO sucess: ^(id responseObject) {
        [allDatas addObject:responseObject];
        dispatch_semaphore_signal(semaphore);
    } failure: ^(NSError *error) {
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    block(allDatas);
}

- (id)parase:(NSData *)jsonData {
    NSError *error;
    return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
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
