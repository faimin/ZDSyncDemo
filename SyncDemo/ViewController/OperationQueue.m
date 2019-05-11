//
//  NSOperationQueue.m
//  ZDSyncDemo
//
//  Created by Zero.D.Saber on 16/1/28.
//  Copyright © 2016年 ZD. All rights reserved.
//

#import "OperationQueue.h"
#import "ZDCommon.h"
#import "ZDSerialOperation.h"

@interface OperationQueue ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation OperationQueue

- (void)dealloc {
    NSLog(@"OperationQueue释放了");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = ZD_RandomColor();
    
    [self operationQueueSync];
    [self serialOperation];
    [self afSync];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)operationQueueSync {
    NSOperationQueue *myOperationQueue = [[NSOperationQueue alloc] init];
    myOperationQueue.maxConcurrentOperationCount = 10;
    
    
    [myOperationQueue addOperationWithBlock:^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[1]]];
        UIImage *image = [UIImage imageWithData:data];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.imageView.image = image;
        }];
        NSLog(@"第1张image下载完毕");
    }];
    
    
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[2]]];
        UIImage *image = [UIImage imageWithData:data];
        if ([NSThread isMainThread]) {
            NSLog(@"主线程");
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.imageView.image = image;
        }];
        NSLog(@"第2张image下载完毕");
    }];
    [myOperationQueue addOperation:blockOperation];
    //支持kvo
    //[myOperationQueue addObserver:self forKeyPath:NSStringFromSelector(@selector(isFinished)) options:NSKeyValueObservingOptionNew context:nil];
    
    
    [myOperationQueue addOperationWithBlock:^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[3]]];
        UIImage *image = [UIImage imageWithData:data];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.imageView.image = image;
        }];
        NSLog(@"第3张image下载完毕");
    }];

    [myOperationQueue waitUntilAllOperationsAreFinished];
    
    NSLog(@"都下载完毕");
}

- (void)serialOperation {
    NSMutableArray *allDatas = @[].mutableCopy;
    
    NSOperationQueue *myOperationQueue = [[NSOperationQueue alloc] init];
    myOperationQueue.maxConcurrentOperationCount = 1;
    
    ZDSerialOperation *op1 = [ZDSerialOperation operationWithBlock:^(ZDOnComplteBlock  _Nonnull taskFinishCallback) {
        NSURLSessionDataTask *task1 = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:MovieAPI] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [allDatas addObject:[self decodeData:data]];
            NSLog(@"第一个任务结束");
            taskFinishCallback(YES);
        }];
        [task1 resume];
    }];
    
    ZDSerialOperation *op2 = [ZDSerialOperation operationWithBlock:^(ZDOnComplteBlock  _Nonnull taskFinishCallback) {
        NSURLSessionDataTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:WeatherAPI] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [allDatas addObject:[self decodeData:data]];
            NSLog(@"第二个任务结束");
            taskFinishCallback(YES);
        }];
        [task2 resume];
    }];
    
    [myOperationQueue addOperations:@[op1, op2] waitUntilFinished:YES];
    __unused id result = allDatas;
    NSLog(@"都下载完毕");
}

- (void)afSync {
    AFHTTPRequestOperation *operation1 = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:MovieAPI]]];
    [operation1 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@", [self decodeData:responseObject]);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    [operation1 resume];
    
    AFHTTPRequestOperation *operation2 = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:WeatherAPI]]];
    [operation2 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@", [self decodeData:responseObject]);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    [operation2 resume];
    
    NSArray *operations = [AFHTTPRequestOperation batchOfRequestOperations:@[operation1, operation2] progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"%ld/%ld", numberOfFinishedOperations, totalNumberOfOperations);
    } completionBlock:^(NSArray * _Nonnull operations) {
        NSLog(@"批处理结束");
    }];
    
    [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
    NSLog(@"打印一下");
}

- (id)decodeData:(id)data {
    NSError *error;
    return [data isKindOfClass:[NSData class]] ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error] : data;
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
