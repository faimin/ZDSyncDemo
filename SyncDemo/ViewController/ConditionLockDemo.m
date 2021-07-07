//
//  ConditionLockDemo.m
//  ZDSyncDemo
//
//  Created by Zero.D.Saber on 2021/7/7.
//  Copyright © 2021 ZD. All rights reserved.
//

#import "ConditionLockDemo.h"
#import "ZDCommon.h"

@interface ConditionLockDemo ()
@property (nonatomic, strong) NSMutableArray *allDatas;
@end

@implementation ConditionLockDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.cyanColor;
    // Do any additional setup after loading the view.
    
    [self conditionLock];
}

- (void)conditionLock {
    NSConditionLock *conditionLock = [[NSConditionLock alloc] initWithCondition:100];
    
    // 请求顺序执行
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        // 与condition 100相同，不会阻塞，继续往下执行
        [conditionLock lockWhenCondition:100];
        [[ZAFNetWorkService shareInstance] requestWithURL:WeatherAPI params:nil httpMethod:@"get" hasCertificate:NO sucess: ^(id responseObject) {
            [self.allDatas addObject:responseObject];
            [conditionLock unlockWithCondition:37];
        } failure: ^(NSError *error) {
            [conditionLock unlockWithCondition:37];
        }];
        
        // 与condition 100不相同，阻塞等待
        [conditionLock lockWhenCondition:37];
        [[ZAFNetWorkService shareInstance] requestWithURL:WeatherAPI params:nil httpMethod:@"get" hasCertificate:NO sucess: ^(id responseObject) {
            [self.allDatas addObject:responseObject];
            [conditionLock unlockWithCondition:3000];
        } failure: ^(NSError *error) {
            [conditionLock unlockWithCondition:3000];
        }];
        
        // 与condition 100不相同，阻塞等待，直到condition变为3000
        [conditionLock lockWhenCondition:3000];
        NSLog(@"最后一行 ： %@", self.allDatas);
    });
    
}

- (void)condition {
    // 和信号量的操作有点像
    NSCondition *condition = [[NSCondition alloc] init];
    
    // 请求顺序执行
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        [[ZAFNetWorkService shareInstance] requestWithURL:WeatherAPI params:nil httpMethod:@"get" hasCertificate:NO sucess: ^(id responseObject) {
            [self.allDatas addObject:responseObject];
            [condition signal];
        } failure: ^(NSError *error) {
            [condition signal];
        }];
        
        [[ZAFNetWorkService shareInstance] requestWithURL:WeatherAPI params:nil httpMethod:@"get" hasCertificate:NO sucess: ^(id responseObject) {
            [self.allDatas addObject:responseObject];
            [condition signal];
        } failure: ^(NSError *error) {
            [condition signal];
        }];
        
        
        [condition wait];
        [condition wait];
        NSLog(@"最后一行 ：%d, %@", __LINE__, self.allDatas);
    });
    
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
