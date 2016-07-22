//
// ZDPromiseController.m
// BoltsDemo
//
// Created by 符现超 on 16/1/22.
// Copyright © 2016年 ZD. All rights reserved.
//

#import "PromiseController.h"
#import "ZDCommon.h"
#import <PromiseKit.h>

@interface PromiseController ()
@property (weak, nonatomic) IBOutlet UITextView *textview;
@end

@implementation PromiseController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self promise];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)promise {
    PMKPromise *promise = [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        [[ZAFNetWorkService shareInstance] requestWithURL:@"http://api.douban.com/v2/movie/top250" params:nil httpMethod:@"get" hasCertificate:NO sucess: ^(id responseObject) {
            // 多个参数的时候用PMKManifold
            //fulfill(PMKManifold(responseObject));
            fulfill(responseObject);
        } failure: ^(NSError *error) {
            reject(error);
        }];
    }];
    
    __weak __typeof(&*self)weakSelf = self;
    promise.then(^(id value){
        __strong __typeof(&*weakSelf)self = weakSelf;
        NSLog(@"1--->%@", @"第一次");
        self.textview.text = value;
    });
    
    promise.then(^(id value){
        NSLog(@"2--->%@", @"第二次");
    });
}

/*
 * #pragma mark - Navigation
 *
 *  // In a storyboard-based application, you will often want to do a little preparation before navigation
 *  - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 *   // Get the new view controller using [segue destinationViewController].
 *   // Pass the selected object to the new view controller.
 *  }
 */

@end
