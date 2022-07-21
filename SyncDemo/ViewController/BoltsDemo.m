//
// ViewController.m
// BoltsDemo
//
// Created by Zero.D.Saber on 15/8/30.
// Copyright (c) 2015年 ZD. All rights reserved.
// https://github.com/BoltsFramework/Bolts-ObjC

#import "BoltsDemo.h"
#import <libkern/OSAtomic.h>
#import <Bolts/Bolts.h>
#import "ZAFNetWorkService.h"
#import "ZDCommon.h"

@interface BoltsDemo ()
@property (weak, nonatomic) IBOutlet UIView *testView;
@end

@implementation BoltsDemo

#pragma mark - lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = ZD_RandomColor();
    [self viewTest];
    
    volatile int32_t t = 0;
    bool isOK = OSAtomicCompareAndSwap32Barrier(0, 1, &t);
    uint32_t m = OSAtomicIncrement32Barrier(&t);    // t+1
    uint32_t n = OSAtomicDecrement32(&t);           // t-1
    NSLog(@"%@, t = %d, m = %d, n = %d", isOK ? @"YES" : @"NO", t, m, n);
    
    /**
     1、每个task对象维护着一个属于它的数组（用来盛放回调block），每次task被continueWithBlock：（类似于信号被订阅）后，都会把这个block放入数组callbacks中，用来数据返回时的回调。
     2、当有结果后，手动调用setResult：，然后会拿到task的callbacks数组，进行遍历回调，然后continue的那个block会执行。
     */
    BFTask *task1 = [self taskTest1];
    BFTask *task2 = [self taskTest2];
    NSArray<BFTask *> *taskArray = @[task1, task2];
    [[BFTask taskForCompletionOfAllTasks:taskArray] continueWithBlock: ^id (BFTask *task) {
        if (task.error) {
            NSLog(@"失败：%@", task.error.localizedDescription);
        }
        else {
            NSLog(@"成功：%@", task.result);
        }
        return nil;
    }];
}

- (void)viewTest {
    self.testView.layoutMargins = UIEdgeInsetsMake(100, 100, 100, 100);
    //self.testView.preservesSuperviewLayoutMargins = YES;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = ZD_RandomColor();
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.layoutMargins = UIEdgeInsetsMake(20, 20, 20, 20);
    view.preservesSuperviewLayoutMargins = YES;
    [self.view addSubview:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Task

- (BFTask *)taskTest1 {
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];

    [[ZAFNetWorkService shareInstance] requestWithURL:MovieAPI params:nil httpMethod:HTTPMethod_GET hasCertificate:NO sucess: ^(id responseObject) {
        NSLog(@"1.--->%@", [NSDate date]);
        [taskSource setResult:responseObject];
    } failure: ^(NSError *error) {
        [taskSource setError:error];
    }];

    return taskSource.task;
}

- (BFTask *)taskTest2 {
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];

    [[ZAFNetWorkService shareInstance] requestWithURL:WeatherAPI params:nil httpMethod:HTTPMethod_GET hasCertificate:NO sucess: ^(id responseObject) {
        NSLog(@"2.--->%@", [NSDate date]);
        [taskSource setResult:responseObject];
    } failure: ^(NSError *error) {
        [taskSource setError:error];
    }];

    return taskSource.task;
}

@end
