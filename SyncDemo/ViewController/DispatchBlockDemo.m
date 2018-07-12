//
//  DispatchBlockDemo.m
//  ZDSyncDemo
//
//  Created by Zero.D.Saber on 2018/7/12.
//  Copyright © 2018年 ZD. All rights reserved.
//

#import "DispatchBlockDemo.h"
#import "ZDCommon.h"

@interface DispatchBlockDemo ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation DispatchBlockDemo

- (void)dealloc {
    NSLog(@"OperationQueue释放了");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = ZD_RandomColor();
    
    [self dispatchBlockSync];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dispatchBlockSync {
    // relative_priority 参数要 QOS_MIN_RELATIVE_PRIORITY < relative_priority < 0
    dispatch_queue_t queue = dispatch_queue_create("com.zd.block.queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_UTILITY, QOS_MIN_RELATIVE_PRIORITY+2));
    
    dispatch_async(queue, ^{
        dispatch_block_t block1 = dispatch_block_create_with_qos_class(DISPATCH_BLOCK_ASSIGN_CURRENT, QOS_CLASS_UTILITY, QOS_MIN_RELATIVE_PRIORITY+1, ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[1]]];
            UIImage *image = [UIImage imageWithData:data];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.imageView.image = image;
            }];
            NSLog(@"第1张image下载完毕");
            //sleep(3);
        });
        
        dispatch_block_t block2 = dispatch_block_create_with_qos_class(DISPATCH_BLOCK_ASSIGN_CURRENT, QOS_CLASS_UTILITY, QOS_MIN_RELATIVE_PRIORITY+1, ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[1]]];
            UIImage *image = [UIImage imageWithData:data];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.imageView.image = image;
            }];
            NSLog(@"第2张image下载完毕");
        });
        
        dispatch_async(queue, block1);
        
        // 第一个闭包执行完后会接着执行第二个，有点闭包顺序执行的意思
        // 该函数有三个参数：第一参数是需要观察的block，第二个参数是被通知的block提交执行的目标queue，第三参数是当需要被通知执行的block
        dispatch_block_notify(block1, dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), block2);
        
        // 会阻塞当前线程，所以不能放在主线程
        dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2*NSEC_PER_SEC));
        long result = dispatch_block_wait(block2, timeout);
        if (result == 0) {
            NSLog(@"都下载完毕");
        } else {
            NSLog(@"下载超时");
            dispatch_block_cancel(block2);
            NSLog(@"取消剩余任务");
        }
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
