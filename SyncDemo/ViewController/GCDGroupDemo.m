//
//  GCD.m
//  ZDSyncDemo
//
//  Created by Zero.D.Saber on 16/1/28.
//  Copyright © 2016年 ZD. All rights reserved.
//

#import "GCDGroupDemo.h"
#import "ZDCommon.h"

@interface GCDGroupDemo ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation GCDGroupDemo

- (void)dealloc {
    NSLog(@"释放了");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = ZD_RandomColor();
    //[self GCDSync1];
    [self GCDSync2];
    //[self GCDSync3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)GCDSync1 {
    dispatch_queue_t queue = dispatch_queue_create("myQueue1", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    zd_weakify(self)
    dispatch_group_async(group, queue, ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[1]]];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            zd_strongify(self)
            self.imageView.image = image;
            NSLog(@"第1张图");
        });
    });
    
    dispatch_group_async(group, queue, ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[2]]];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            zd_strongify(self)
            self.imageView.image = image;
            NSLog(@"第2张图");
        });
    });
    
    dispatch_group_async(group, queue, ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[3]]];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            zd_strongify(self)
            self.imageView.image = image;
            NSLog(@"第3张图");
        });
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"下载完毕");
    });
}

// 不会阻塞主线程
- (void)GCDSync2 {
    zd_weakify(self)
    
    NSMutableArray *allDatas = @[].mutableCopy;
    
    dispatch_queue_t queue = dispatch_queue_create("myQueue2", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLSessionDataTask *task1 = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:MovieAPI] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [allDatas addObject:[self parase:data]];
            dispatch_group_leave(group);
            NSLog(@"第1张图");
        }];
        [task1 resume];
    });
    
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLSessionDataTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:WeatherAPI] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [allDatas addObject:[self parase:data]];
            dispatch_group_leave(group);
            NSLog(@"第二个请求结束");
        }];
        [task2 resume];
    });
    
    
    // 此方法必须是自定义的queue
    dispatch_group_notify(group, queue, ^{
        NSLog(@"所有图片和网络请求全都下载完毕");
    });
    
    dispatch_group_enter(group);
    NSData *data3 = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[2]]];
    UIImage *image3 = [UIImage imageWithData:data3];
    dispatch_async(dispatch_get_main_queue(), ^{
        zd_strongify(self)
        self.imageView.image = image3;
        dispatch_group_leave(group);
        NSLog(@"第3张图");
    });
    
    NSLog(@"最后一行");
}


- (void)GCDSync3 {
    zd_weakify(self)
    dispatch_queue_t targetQueue = dispatch_queue_create("targetQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_queue_t queue1 = dispatch_queue_create("queue1", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t queue2 = dispatch_queue_create("queue2", DISPATCH_QUEUE_CONCURRENT);
    /// 目标队列：http://www.tuicool.com/articles/feqQvmj
    /// 每一个你创建的队列都必须有一个目标队列。默认情况下，是优先级为 DISPATCH_QUEUE_PRIORITY_DEFAULT 的全局并发队列。
    /// 队列里每一个准备好要执行的block，将会被重新加入到这个队列的目标队列里去执行。
    /// 队列会在他的目标队列上执行任务
    dispatch_set_target_queue(queue1, targetQueue);
    dispatch_set_target_queue(queue2, targetQueue);
    
    NSData *data1 = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[0]]];
    UIImage *image1 = [UIImage imageWithData:data1];
    dispatch_async(queue1, ^{
        zd_strongify(self)
        self.imageView.image = image1;
        NSLog(@"第1张图");
    });
    
    NSData *data2 = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[1]]];
    UIImage *image2 = [UIImage imageWithData:data2];
    dispatch_async(queue2, ^{
        zd_strongify(self)
        self.imageView.image = image2;
        NSLog(@"第2张图");
    });
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
