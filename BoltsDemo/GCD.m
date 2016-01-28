//
//  GCD.m
//  ZDSyncDemo
//
//  Created by 符现超 on 16/1/28.
//  Copyright © 2016年 ZD. All rights reserved.
//

#import "GCD.h"
#import "ZDCommon.h"

@interface GCD ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (assign) NSUInteger count;

@end

@implementation GCD

- (void)dealloc
{
    NSLog(@"释放了");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self GCDSync];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)GCDSync
{
    dispatch_queue_t queue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    __weak __typeof(&*self)weakSelf = self;
    dispatch_group_async(group, queue, ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[1]]];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            //__strong __typeof(*&weakSelf)self = weakSelf;
            self.imageView.image = image;
            NSLog(@"第1张图");
        });
    });
    
    dispatch_group_async(group, queue, ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[2]]];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            //__strong __typeof(*&weakSelf)self = weakSelf;
            self.imageView.image = image;
            NSLog(@"第2张图");
        });
    });
    
    dispatch_group_async(group, queue, ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[3]]];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            //__strong __typeof(*&weakSelf)self = weakSelf;
            self.imageView.image = image;
            NSLog(@"第3张图");
        });
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"下载完毕");
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
