//
//  GCD.m
//  ZDSyncDemo
//
//  Created by 符现超 on 16/1/28.
//  Copyright © 2016年 ZD. All rights reserved.
//

#import "GCDDemo.h"
#import "ZDCommon.h"

@interface GCDDemo ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (assign) NSUInteger count;

@end

@implementation GCDDemo

- (void)dealloc {
    NSLog(@"释放了");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self GCDSync1];
    [self GCDSync2];
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

- (void)GCDSync2 {
    zd_weakify(self)
    dispatch_queue_t queue = dispatch_queue_create("myQueue2", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    NSData *data1 = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[0]]];
    UIImage *image1 = [UIImage imageWithData:data1];
    dispatch_async(dispatch_get_main_queue(), ^{
        zd_strongify(self)
        self.imageView.image = image1;
        dispatch_group_leave(group);
        NSLog(@"第1张图");
    });
    
    dispatch_group_enter(group);
    NSData *data2 = [NSData dataWithContentsOfURL:[NSURL URLWithString:images()[1]]];
    UIImage *image2 = [UIImage imageWithData:data2];
    dispatch_async(dispatch_get_main_queue(), ^{
        zd_strongify(self)
        self.imageView.image = image2;
        dispatch_group_leave(group);
        NSLog(@"第2张图");
    });
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"下载完毕");
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
