//
// ViewController.m
// BoltsDemo
//
// Created by 符现超 on 15/8/30.
// Copyright (c) 2015年 ZD. All rights reserved.
// https://github.com/BoltsFramework/Bolts-iOS

#import "BoltsController.h"
#import <Bolts.h>
#import "ZAFNetWorkService.h"

@interface BoltsController ()

@end

@implementation BoltsController

#pragma mark - lifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    BFTask  *task      = [self taskTest1];
    BFTask  *task2     = [self taskTest2];
    NSArray *taskArray = @[task, task2];
    [[BFTask taskForCompletionOfAllTasks:taskArray] continueWithBlock: ^id (BFTask *task) {
        if (task.error)
        {
            NSLog(@"失败：%@", task.error);
        }
        else
        {
            NSLog(@"成功：%@", task.result);
        }
        return nil;
    }];
} /* viewDidLoad */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Task

- (BFTask*)taskTest1
{
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];

    [[ZAFNetWorkService shareInstance] requestWithURL:@"http://api.douban.com/v2/movie/top250" params:nil httpMethod:@"get" hasCertificate:NO sucess: ^(id responseObject) {
        NSLog(@"1.--->%@", [NSDate date]);
        [taskSource setResult:responseObject];
    } failure: ^(NSError *error) {
        [taskSource setError:error];
    }];

    return taskSource.task;
} /* taskTest1 */

- (BFTask*)taskTest2
{
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];

    [[ZAFNetWorkService shareInstance] requestWithURL:@"http://www.weather.com.cn/data/cityinfo/101010100.html" params:nil httpMethod:@"get" hasCertificate:NO sucess: ^(id responseObject) {
        NSLog(@"2.--->%@", [NSDate date]);
        [taskSource setResult:responseObject];
    } failure: ^(NSError *error) {
        [taskSource setError:error];
    }];

    return taskSource.task;
} /* taskTest2 */

@end
