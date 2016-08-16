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
    [self semaphore];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)semaphore {
    NSMutableArray *allDatas = [[NSMutableArray alloc] init];
    dispatch_queue_t queue = dispatch_queue_create("ZD.Queue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    [[ZAFNetWorkService shareInstance] requestWithURL:MovieAPI params:nil httpMethod:@"get" hasCertificate:NO sucess: ^(id responseObject) {
        [allDatas addObject:responseObject];
        dispatch_semaphore_signal(semaphore);
    } failure: ^(NSError *error) {
        dispatch_semaphore_signal(semaphore);
    }];
//    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//    dispatch_async(queue, ^{
//    });
    
    [[ZAFNetWorkService shareInstance] requestWithURL:WeatherAPI params:nil httpMethod:@"get" hasCertificate:NO sucess: ^(id responseObject) {
        [allDatas addObject:responseObject];
        dispatch_semaphore_signal(semaphore);
    } failure: ^(NSError *error) {
        dispatch_semaphore_signal(semaphore);
    }];
//    dispatch_async(queue, ^{
//    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    NSLog(@"%@", allDatas);
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
