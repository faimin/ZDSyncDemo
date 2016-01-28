//
//  NSOperationQueue.m
//  ZDSyncDemo
//
//  Created by 符现超 on 16/1/28.
//  Copyright © 2016年 ZD. All rights reserved.
//

#import "OperationQueue.h"
#import "ZDCommon.h"

@interface OperationQueue ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation OperationQueue

- (void)dealloc
{
    NSLog(@"释放了");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self operationQueueSync];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)operationQueueSync
{
    NSOperationQueue *myOperationQueue = [[NSOperationQueue alloc] init];
    myOperationQueue.maxConcurrentOperationCount = 10;
    
    __weak __typeof(&*self)weakSelf = self;
    [myOperationQueue addOperationWithBlock:^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[1]]];
        UIImage *image = [UIImage imageWithData:data];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //__strong __typeof(*&weakSelf)self = weakSelf;
            self.imageView.image = image;
        }];
        NSLog(@"第1张image下载完毕");
    }];
    
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[2]]];
        UIImage *image = [UIImage imageWithData:data];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //__strong __typeof(*&weakSelf)self = weakSelf;
            self.imageView.image = image;
        }];
        NSLog(@"第2张image下载完毕");
    }];
    [myOperationQueue addOperation:blockOperation];
    
    [myOperationQueue addOperationWithBlock:^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[3]]];
        UIImage *image = [UIImage imageWithData:data];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //__strong __typeof(*&weakSelf)self = weakSelf;
            self.imageView.image = image;
        }];
        NSLog(@"第3张image下载完毕");
    }];

    [myOperationQueue waitUntilAllOperationsAreFinished];
    
    NSLog(@"都下载完毕");
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
