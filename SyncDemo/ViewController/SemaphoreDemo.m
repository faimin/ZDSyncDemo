//
//  SemaphoreDemo.m
//  ZDSyncDemo
//
//  Created by Zero.D.Saber on 16/8/16.
//  Copyright © 2016年 ZD. All rights reserved.
//

#import "SemaphoreDemo.h"
#import "ZDCommon.h"

@interface SemaphoreDemo ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation SemaphoreDemo

- (void)dealloc {
    NSLog(@"%s, %d", __PRETTY_FUNCTION__, __LINE__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self request];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}

- (void)request {
    dispatch_queue_t myQueue = dispatch_queue_create("MyQueue.zd", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(myQueue, ^{
        [self semaphore:^(id data) {
            self.textView.text = [self jsonString:data];
            NSLog(@"第一个回调成功");
        }];
        
        [self semaphoreTempWithResult:^(id result) {
            NSLog(@"第二个回调成功");
        }];
        
        [self semaphoreGroupWithResult:^(id result) {
            NSLog(@"第三个回调成功");
        }];
        
        [self syncExecuteCocurrentRequest:^(id result) {
            NSLog(@"第四个回调成功");
        }];
        
    });
}

- (void)semaphore:(void(^)(id data))callBack {
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
    
    // `wait`会阻塞当前所在线程,为了防止它阻塞主线程,需要在子线程处理
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        callBack(allDatas);
    });
}

// 虽然AF本身就在子线程进行的网络请求,但是当进行结果回调时进行了回到主线程的操作,所以下面的网络请求需要放在子线程操作。如果下面的网络请求放在主线程处理的话,会发生死锁的情况,谨记!
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
    
    __unused BOOL isMainThread = [NSThread isMainThread];
    dispatch_sync(dispatch_get_main_queue(), ^{
        block(allDatas);
    });
}

- (void)semaphoreGroupWithResult:(void(^)(id result))block {
    
    NSMutableArray *allDatas = [[NSMutableArray alloc] init];
    
    dispatch_group_t zdGroup = dispatch_group_create();
    
    dispatch_group_async(zdGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
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
    });
    
    /*
     // 在子线程进行回调
    dispatch_group_notify(zdGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        block(allDatas);
        __unused BOOL isMainThread = [NSThread isMainThread];
        NSLog(@"数组item个数 => %zd", allDatas.count);
    });
    */
    
    // 回到主线程回调
    dispatch_group_notify(zdGroup, dispatch_get_main_queue(), ^{
        block(allDatas);
        NSLog(@"第三个结果数组item个数 => %zd", allDatas.count);
    });
    
    NSLog(@"第三个请求:%@", [NSThread isMainThread] ? @"主线程" : @"子线程");
}

//异步请求顺序执行
- (void)syncExecuteCocurrentRequest:(void(^)(id result))block {
    
    NSMutableArray *allDatas = [[NSMutableArray alloc] init];
    // 创建一个信号量
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSURLSessionDataTask *task1 = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:MovieAPI] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [allDatas addObject:[self parase:data]];
        dispatch_semaphore_signal(semaphore);
    }];
    [task1 resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);  //-1
    
    NSURLSessionDataTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:WeatherAPI] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [allDatas addObject:[self parase:data]];
        dispatch_semaphore_signal(semaphore);
    }];
    [task2 resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    NSLog(@"第四个结果数组item个数 => %zd", allDatas.count);
    NSLog(@"第四个请求:%@", [NSThread isMainThread] ? @"主线程" : @"子线程");
    
    block(allDatas);
}

#pragma mark - Private Method

- (id)parase:(NSData *)jsonData {
    NSError *error;
    return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
}

- (NSString *)jsonString:(id)temps {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:temps
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *strs = [[NSString alloc] initWithData:jsonData
                                           encoding:NSUTF8StringEncoding];
    return strs;
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
