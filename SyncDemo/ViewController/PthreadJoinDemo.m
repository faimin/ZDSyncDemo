//
//  PthreadJoin.m
//  ZDSyncDemo
//
//  Created by Zero.D.Saber on 2017/7/10.
//  Copyright © 2017年 ZD. All rights reserved.
//

#import "PthreadJoinDemo.h"
#import <pthread/pthread.h>
#import "ZDCommon.h"

@interface PthreadJoinDemo ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation PthreadJoinDemo

- (void)dealloc {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self pthreadSync];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

void *task1(void *param) {
    NSMutableArray *allDatas = (__bridge NSMutableArray *)param;
    
    NSURLSessionDataTask *task1 = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:MovieAPI] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [allDatas addObject:data];
        NSLog(@"第1个请求结束");
    }];
    [task1 resume];
    
    return NULL;
}

void *task2(void *param) {
    NSMutableArray *allDatas = (__bridge NSMutableArray *)param;
    
    NSURLSessionDataTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:WeatherAPI] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [allDatas addObject:data];
        NSLog(@"第2个请求结束");
    }];
    [task2 resume];
    sleep(5);
    return (void *)2;
}

// http://www.tuicool.com/articles/iUjimeY
// http://blog.csdn.net/tototuzuoquan/article/details/39553427
- (void)pthreadSync {
    
    NSMutableArray *allDatas = @[].mutableCopy;
    
    pthread_t pthread1, pthread2;
    void *tret;
    
    // 参数1  线程编号的地址
    // 参数2  线程的属性
    // 参数3  线程要执行的函数（函数指针）（第三个参数可以，demo，*demo, 一般用&demo）
    // 参数4  线程要执行的函数的参数
    int error = pthread_create(&pthread1, NULL, &task1, (__bridge void*)allDatas);
    if (error != 0) {
        printf("can't create thread1");
    }
    
    error = pthread_create(&pthread2, NULL, &task2, (__bridge void*)allDatas);
    if (error != 0) {
        printf("can't create thread2");
    }
    
    // tret是线程pthread1执行函数的返回值(接收退出线程传递出的返回值),即task1()返回值
    // 阻塞当前线程,直到线程上的执行函数返回值
    pthread_join(pthread1, &tret);
    printf("线程1返回值：%d\n", (int)tret);
    
    pthread_join(pthread2, &tret);
    printf("线程2返回值：%d\n", (int)tret);
    
    // 如果调用了取消操作,清理函数就会在函数结束前调用
    // 第一个参数是清理函数,第二个参数是清理函数的参数
    //pthread_cleanup_push(<#func#>, <#val#>);
    
    // 非零: 表示需要调用清理函数
    //pthread_cleanup_pop(1);
    
    //NSData *data3 = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[2]]];
    //NSLog(@"第3张图");
    
    NSLog(@"最后一行");
}

#pragma mark - Private Method

- (id)parase:(NSData *)jsonData {
    NSError *error;
    return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
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
