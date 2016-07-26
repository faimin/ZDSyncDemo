//
//  RACDemo.m
//  ZDSyncDemo
//
//  Created by 符现超 on 16/7/25.
//  Copyright © 2016年 ZD. All rights reserved.
//

#import "RACDemo.h"
#import "ReactiveCocoa.h"
#import "ZDCommon.h"

@interface RACDemo ()

@end

@implementation RACDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self rac];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rac {
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[ZAFNetWorkService shareInstance] requestWithURL:MovieAPI params:nil httpMethod:@"get" hasCertificate:NO sucess: ^(id responseObject) {
            [subscriber sendNext:responseObject];
            [subscriber sendCompleted];
        } failure: ^(NSError *error) {
            [subscriber sendError:error];
            [subscriber sendCompleted];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"异步请求结束了");
        }];
    }];
    
    [signal subscribeNext:^(id x) {
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
