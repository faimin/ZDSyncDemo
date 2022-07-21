//
//  RACDemo.m
//  ZDSyncDemo
//
//  Created by Zero.D.Saber on 16/7/25.
//  Copyright © 2016年 ZD. All rights reserved.
//

#import "RACDemo.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "ZDCommon.h"

@interface RACDemo ()

@end

@implementation RACDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = ZD_RandomColor();
    [self rac];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rac {
    RACSignal *signal1 = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[ZAFNetWorkService shareInstance] requestWithURL:WeatherAPI params:nil httpMethod:HTTPMethod_GET hasCertificate:NO sucess: ^(id responseObject) {
            [subscriber sendNext:responseObject];
            [subscriber sendCompleted];
        } failure: ^(NSError *error) {
            [subscriber sendError:error];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"异步请求1结束了");
        }];
    }] replayLazily];
    
    RACSignal *signal2 = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[ZAFNetWorkService shareInstance] requestWithURL:WeatherAPI params:nil httpMethod:HTTPMethod_GET hasCertificate:NO sucess: ^(id responseObject) {
            [subscriber sendNext:responseObject];
            [subscriber sendCompleted];
        } failure: ^(NSError *error) {
            [subscriber sendError:error];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"异步请求2结束了");
        }];
    }] replayLazily];
    
    // 方式1
    [[RACSignal zip:@[signal1, signal2]] subscribeNext:^(RACTuple * _Nullable x) {
        RACTupleUnpack(id v1, id v2) = x;
        NSLog(@"v1 = %@, v2 = %@", v1, v2);
    }];
    
    // 方式2
    // 先拼接后收集
    [[[signal1 concat:signal2] collect] subscribeNext:^(NSArray<NSDictionary *> *x) {
        NSLog(@"%@", x);
    }];
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
