//
//  PromisesObjCDemo.m
//  ZDSyncDemo
//
//  Created by Zero.D.Saber on 2018/4/27.
//  Copyright © 2018年 ZD. All rights reserved.
//

#import "PromisesObjCDemo.h"
#import <PromisesObjC/FBLPromises.h>
#import "ZDCommon.h"

@interface PromisesObjCDemo ()

@end

@implementation PromisesObjCDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup {
    self.view.backgroundColor = ZD_RandomColor();
    [self setupPromises];
}

- (void)setupPromises {
    FBLPromise *promise1 = [FBLPromise async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        [[ZAFNetWorkService shareInstance] requestWithURL:MovieAPI params:nil httpMethod:@"get" hasCertificate:NO sucess: ^(id responseObject) {
            fulfill(responseObject);
        } failure: ^(NSError *error) {
            reject(error);
        }];
    }]
    .then(^id(id value){
        NSLog(@"11 = %@", value);
        return @(11);
    })
    .then(^id(NSNumber *value){
        NSLog(@"12 = %@", value);
        return value;
    });
    
    FBLPromise *promise2 = [FBLPromise async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        [[ZAFNetWorkService shareInstance] requestWithURL:WeatherAPI params:nil httpMethod:@"get" hasCertificate:NO sucess: ^(id responseObject) {
            fulfill(responseObject);
        } failure: ^(NSError *error) {
            reject(error);
        }];
    }]
    .then(^id(id value){
        NSLog(@"21 = %@", value);
        return @(21);
    });
    
    [[FBLPromise any:@[promise1, promise2]] then:^id _Nullable(NSArray * _Nullable value) {
        NSLog(@"any = %@", value);
        return nil;
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
