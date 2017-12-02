//
//  Operation.m
//  ZDSyncDemo
//
//  Created by Zero.D.Saber on 2017/12/2.
//  Copyright © 2017年 ZD. All rights reserved.
//

#import "OperationDemo.h"
#import "ZDCommon.h"

@interface OperationDemo ()

@end

@implementation OperationDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

- (void)setup {
    NSLog(@"主线程开始");
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[0]]];
        UIImage *image = [UIImage imageWithData:data];
        NSLog(@"0 = %@", image);
    }];
    
    [op addExecutionBlock:^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[1]]];
        UIImage *image = [UIImage imageWithData:data];
        NSLog(@"1 = %@", image);
    }];
    
    [op addExecutionBlock:^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[2]]];
        UIImage *image = [UIImage imageWithData:data];
        NSLog(@"2 = %@", image);
    }];
    
    [op addExecutionBlock:^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[3]]];
        UIImage *image = [UIImage imageWithData:data];
        NSLog(@"3 = %@", image);
    }];
    
    [op waitUntilFinished];
    NSLog(@"执行完毕");
    NSLog(@"主线程结束");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
